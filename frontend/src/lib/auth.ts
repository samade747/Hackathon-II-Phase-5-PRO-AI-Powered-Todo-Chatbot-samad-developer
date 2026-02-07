// MOCKING BETTER AUTH TO BYPASS WINDOWS SYMLINK ISSUE WITH BETTER-SQLITE3
// The project primarily uses Supabase for authentication anyway.

export const auth = {
    handler: async () => new Response("Better Auth is disabled in local dev due to symlink issues.", { status: 200 }),
    api: {},
    secret: "mock-secret"
} as any;
