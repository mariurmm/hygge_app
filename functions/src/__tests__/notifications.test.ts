/**
 * Unit tests for Firebase Functions (notifications + booking triggers).
 *
 * Strategy:
 *  - Mock `firebase-admin` so no real Firebase connection is needed.
 *  - Mock `firebase-functions/scheduler` and `firebase-functions/firestore`
 *    to expose the inner handler via `.run`, so we can call it directly.
 *  - Mock `firebase-functions/logger` to suppress output.
 */

// ─── Mock firebase-functions wrappers ────────────────────────────────────────

type ScheduleHandler = () => Promise<void>;
type DocUpdateHandler = (event: unknown) => Promise<void>;

const capturedHandlers: {
  sendClassReminders?: ScheduleHandler;
  processAutoConfirm?: ScheduleHandler;
  onBookingStatusChanged?: DocUpdateHandler;
} = {};

jest.mock("firebase-functions/scheduler", () => ({
  onSchedule: jest.fn((_config: unknown, handler: ScheduleHandler) => {
    // Identify handler by call order (sendClassReminders first, processAutoConfirm second).
    if (!capturedHandlers.sendClassReminders) {
      capturedHandlers.sendClassReminders = handler;
    } else {
      capturedHandlers.processAutoConfirm = handler;
    }
    return { run: handler };
  }),
}));

jest.mock("firebase-functions/firestore", () => ({
  onDocumentUpdated: jest.fn(
    (_pattern: unknown, handler: DocUpdateHandler) => {
      capturedHandlers.onBookingStatusChanged = handler;
      return { run: handler };
    }
  ),
}));

jest.mock("firebase-functions/logger", () => ({
  logger: {
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    log: jest.fn(),
  },
}));

// ─── Mock firebase-admin ──────────────────────────────────────────────────────

const mockSend = jest.fn();
const mockRunTransaction = jest.fn();
const mockFirestoreData: Record<string, Record<string, unknown>> = {};

function makeMockDoc(path: string) {
  const docData = mockFirestoreData[path];
  return {
    exists: docData !== undefined,
    data: () => docData,
    ref: {
      path,
      update: jest.fn().mockResolvedValue(undefined),
    },
  };
}

function makeQuerySnap(docs: Array<{ path: string; data: Record<string, unknown> }>) {
  return {
    empty: docs.length === 0,
    docs: docs.map((d) => ({
      id: d.path.split("/").pop()!,
      ref: {
        path: d.path,
        update: jest.fn().mockResolvedValue(undefined),
      },
      data: () => d.data,
    })),
  };
}

const mockCollectionImpl = jest.fn();
const mockCollectionGroupImpl = jest.fn();

jest.mock("firebase-admin", () => ({
  initializeApp: jest.fn(),
  firestore: Object.assign(
    jest.fn(() => ({
      collection: mockCollectionImpl,
      collectionGroup: mockCollectionGroupImpl,
      runTransaction: mockRunTransaction,
    })),
    {
      Timestamp: {
        now: jest.fn(() => ({ toMillis: () => Date.now() })),
        fromMillis: jest.fn((ms: number) => ({
          toMillis: () => ms,
          toDate: () => new Date(ms),
        })),
      },
    }
  ),
  messaging: jest.fn(() => ({ send: mockSend })),
}));

// ─── Load the module under test AFTER mocks are set up ───────────────────────

// eslint-disable-next-line @typescript-eslint/no-require-imports
require("../index");

// ─── Helpers ─────────────────────────────────────────────────────────────────

function chainQuery(docs: Array<{ path: string; data: Record<string, unknown> }>) {
  const snap = makeQuerySnap(docs);
  const query = {
    where: jest.fn().mockReturnThis(),
    get: jest.fn().mockResolvedValue(snap),
  };
  return query;
}

// ─── Tests ───────────────────────────────────────────────────────────────────

beforeEach(() => {
  jest.clearAllMocks();
  Object.keys(mockFirestoreData).forEach((k) => delete mockFirestoreData[k]);
});

// ── sendClassReminders ────────────────────────────────────────────────────────

describe("sendClassReminders", () => {
  test("skips processing when no classes in the notification window", async () => {
    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "classes") return chainQuery([]);
      return chainQuery([]);
    });

    await capturedHandlers.sendClassReminders!();

    expect(mockSend).not.toHaveBeenCalled();
  });

  test("skips notification when notificationSent is already true", async () => {
    const classId = "class-1";
    const classSnap = makeQuerySnap([
      {
        path: `classes/${classId}`,
        data: { title: "Yoga", datetime: { toDate: () => new Date() } },
      },
    ]);
    const bookingSnap = makeQuerySnap([
      {
        path: `bookings/user-1/userBookings/bk-1`,
        data: {
          classId,
          status: "pending",
          notificationSent: true, // already sent
        },
      },
    ]);

    let callCount = 0;
    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "classes") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(classSnap) }),
          }),
        };
      }
      return chainQuery([]);
    });
    mockCollectionGroupImpl.mockImplementation(() => {
      callCount++;
      return {
        where: jest.fn().mockReturnValue({
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({
              get: jest.fn().mockResolvedValue(bookingSnap),
            }),
          }),
        }),
      };
    });

    // The query for notificationSent==false returns no docs, so no notification is sent.
    const emptySnap = makeQuerySnap([]);
    mockCollectionGroupImpl.mockReturnValue({
      where: jest.fn().mockReturnValue({
        where: jest.fn().mockReturnValue({
          where: jest.fn().mockReturnValue({
            get: jest.fn().mockResolvedValue(emptySnap),
          }),
        }),
      }),
    });

    await capturedHandlers.sendClassReminders!();

    expect(mockSend).not.toHaveBeenCalled();
    void callCount; // suppress unused warning
  });

  test("skips notification when user has no FCM token", async () => {
    const classId = "class-2";
    const classSnap = makeQuerySnap([
      {
        path: `classes/${classId}`,
        data: { title: "Meditation", datetime: { toDate: () => new Date() } },
      },
    ]);
    const bookingSnap = makeQuerySnap([
      {
        path: `bookings/user-2/userBookings/bk-2`,
        data: { classId, status: "pending", notificationSent: false },
      },
    ]);
    const userSnap = { exists: true, data: () => ({ email: "test@test.com" }) }; // no fcmToken

    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "classes") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(classSnap) }),
          }),
        };
      }
      if (name === "users") {
        return { doc: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(userSnap) }) };
      }
      return chainQuery([]);
    });
    mockCollectionGroupImpl.mockReturnValue({
      where: jest.fn().mockReturnValue({
        where: jest.fn().mockReturnValue({
          where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(bookingSnap) }),
        }),
      }),
    });

    await capturedHandlers.sendClassReminders!();

    expect(mockSend).not.toHaveBeenCalled();
  });

  test("sends FCM and marks notificationSent true when all conditions met", async () => {
    const classId = "class-3";
    const bookingRef = {
      path: `bookings/user-3/userBookings/bk-3`,
      update: jest.fn().mockResolvedValue(undefined),
    };
    const classSnap = makeQuerySnap([
      {
        path: `classes/${classId}`,
        data: { title: "Pilates", datetime: { toDate: () => new Date() } },
      },
    ]);
    const bookingSnap = {
      empty: false,
      docs: [
        {
          id: "bk-3",
          ref: bookingRef,
          data: () => ({ classId, status: "pending", notificationSent: false }),
        },
      ],
    };
    const userSnap = {
      exists: true,
      data: () => ({ fcmToken: "token-abc" }),
    };

    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "classes") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(classSnap) }),
          }),
        };
      }
      if (name === "users") {
        return { doc: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(userSnap) }) };
      }
      if (name === "_autoConfirmQueue") {
        return { add: jest.fn().mockResolvedValue(undefined) };
      }
      return chainQuery([]);
    });
    mockCollectionGroupImpl.mockReturnValue({
      where: jest.fn().mockReturnValue({
        where: jest.fn().mockReturnValue({
          where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(bookingSnap) }),
        }),
      }),
    });
    mockSend.mockResolvedValue("message-id");

    await capturedHandlers.sendClassReminders!();

    expect(mockSend).toHaveBeenCalledWith(
      expect.objectContaining({
        token: "token-abc",
        notification: expect.objectContaining({ title: "Напоминание о занятии" }),
        data: expect.objectContaining({ classId, bookingId: "bk-3" }),
      })
    );
    expect(bookingRef.update).toHaveBeenCalledWith({ notificationSent: true });
  });
});

// ── processAutoConfirm ────────────────────────────────────────────────────────

describe("processAutoConfirm", () => {
  test("skips booking that is already confirmed", async () => {
    const queueSnap = makeQuerySnap([
      {
        path: "_autoConfirmQueue/q-1",
        data: { userId: "u1", bookingId: "bk-1", processed: false },
      },
    ]);
    const bookingDocSnap = { exists: true, data: () => ({ status: "confirmed" }) };

    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "_autoConfirmQueue") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(queueSnap) }),
          }),
        };
      }
      if (name === "bookings") {
        return {
          doc: jest.fn().mockReturnValue({
            collection: jest.fn().mockReturnValue({
              doc: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(bookingDocSnap) }),
            }),
          }),
        };
      }
      return chainQuery([]);
    });

    await capturedHandlers.processAutoConfirm!();

    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  test("skips booking that is cancelled", async () => {
    const queueSnap = makeQuerySnap([
      {
        path: "_autoConfirmQueue/q-2",
        data: { userId: "u2", bookingId: "bk-2", processed: false },
      },
    ]);
    const bookingDocSnap = { exists: true, data: () => ({ status: "cancelled" }) };

    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "_autoConfirmQueue") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(queueSnap) }),
          }),
        };
      }
      if (name === "bookings") {
        return {
          doc: jest.fn().mockReturnValue({
            collection: jest.fn().mockReturnValue({
              doc: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(bookingDocSnap) }),
            }),
          }),
        };
      }
      return chainQuery([]);
    });

    await capturedHandlers.processAutoConfirm!();

    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  test("calls runTransaction to confirm when booking is still pending", async () => {
    const queueSnap = makeQuerySnap([
      {
        path: "_autoConfirmQueue/q-3",
        data: { userId: "u3", bookingId: "bk-3", processed: false },
      },
    ]);
    const bookingDocSnap = { exists: true, data: () => ({ status: "pending" }) };
    mockRunTransaction.mockResolvedValue(undefined);

    mockCollectionImpl.mockImplementation((name: string) => {
      if (name === "_autoConfirmQueue") {
        return {
          where: jest.fn().mockReturnValue({
            where: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(queueSnap) }),
          }),
        };
      }
      if (name === "bookings") {
        return {
          doc: jest.fn().mockReturnValue({
            collection: jest.fn().mockReturnValue({
              doc: jest.fn().mockReturnValue({ get: jest.fn().mockResolvedValue(bookingDocSnap) }),
            }),
          }),
        };
      }
      if (name === "subscriptions") {
        return { doc: jest.fn().mockReturnValue({}) };
      }
      return chainQuery([]);
    });

    await capturedHandlers.processAutoConfirm!();

    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
  });
});

// ── onBookingStatusChanged ────────────────────────────────────────────────────

describe("onBookingStatusChanged", () => {
  test("calls runTransaction when status changes to confirmed", async () => {
    mockRunTransaction.mockResolvedValue(undefined);
    mockCollectionImpl.mockImplementation(() => ({
      doc: jest.fn().mockReturnValue({
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({ path: "bookings/u/userBookings/bk" }),
        }),
      }),
    }));

    const event = {
      data: {
        before: { data: () => ({ status: "pending", classId: "c1" }) },
        after: { data: () => ({ status: "confirmed", classId: "c1" }) },
      },
      params: { userId: "u", bookingId: "bk" },
    };

    await capturedHandlers.onBookingStatusChanged!(event);

    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
  });

  test("calls runTransaction to decrement participants when status changes to cancelled", async () => {
    mockRunTransaction.mockResolvedValue(undefined);
    mockCollectionImpl.mockImplementation(() => ({
      doc: jest.fn().mockReturnValue({
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({}),
        }),
      }),
    }));

    const event = {
      data: {
        before: { data: () => ({ status: "pending", classId: "class-1" }) },
        after: { data: () => ({ status: "cancelled", classId: "class-1" }) },
      },
      params: { userId: "u", bookingId: "bk" },
    };

    await capturedHandlers.onBookingStatusChanged!(event);

    // _decrementParticipants calls runTransaction once.
    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
  });

  test("also restores session when cancelled booking was previously confirmed", async () => {
    mockRunTransaction.mockResolvedValue(undefined);
    mockCollectionImpl.mockImplementation(() => ({
      doc: jest.fn().mockReturnValue({
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({}),
        }),
      }),
    }));

    const event = {
      data: {
        before: { data: () => ({ status: "confirmed", classId: "class-1" }) },
        after: { data: () => ({ status: "cancelled", classId: "class-1" }) },
      },
      params: { userId: "u", bookingId: "bk" },
    };

    await capturedHandlers.onBookingStatusChanged!(event);

    // _decrementParticipants + _restoreSession = 2 transactions.
    expect(mockRunTransaction).toHaveBeenCalledTimes(2);
  });

  test("does nothing when status has not changed", async () => {
    const event = {
      data: {
        before: { data: () => ({ status: "pending" }) },
        after: { data: () => ({ status: "pending" }) },
      },
      params: { userId: "u", bookingId: "bk" },
    };

    await capturedHandlers.onBookingStatusChanged!(event);

    expect(mockRunTransaction).not.toHaveBeenCalled();
  });
});
