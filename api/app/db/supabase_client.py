class SupabaseClient:
    def __init__(self):
        # TODO: initialize real Supabase client with env vars.
        self.enabled = False

    async def log_feedback(self, payload: dict) -> None:
        if not self.enabled:
            # In MVP we simply print to console; replace with async insert.
            print("Feedback payload (mocked):", payload)
            return
        # Future: await self.client.table('feedback').insert(payload).execute()
