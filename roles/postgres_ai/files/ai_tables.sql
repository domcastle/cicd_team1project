-- =========================
-- AI Videos (영상 단위)
-- =========================
CREATE TABLE IF NOT EXISTS ai_videos (
  video_id BIGSERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,

  title VARCHAR(255),
  description TEXT,

  status VARCHAR(30) DEFAULT 'processing',
  output_path TEXT,
  duration_seconds INTEGER,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- AI Video Jobs (작업 단위)
-- =========================
CREATE TABLE IF NOT EXISTS ai_video_jobs (
  job_id BIGSERIAL PRIMARY KEY,

  video_id BIGINT NOT NULL,
  job_type VARCHAR(50) NOT NULL,
  status VARCHAR(30) DEFAULT 'pending',

  input_data TEXT,
  output_data TEXT,
  error_message TEXT,

  started_at TIMESTAMP,
  finished_at TIMESTAMP,

  CONSTRAINT fk_job_video
    FOREIGN KEY (video_id)
    REFERENCES ai_videos(video_id)
    ON DELETE CASCADE
);

-- =========================
-- AI Video Assets (파일 메타)
-- =========================
CREATE TABLE IF NOT EXISTS ai_video_assets (
  asset_id BIGSERIAL PRIMARY KEY,

  video_id BIGINT NOT NULL,
  asset_type VARCHAR(50) NOT NULL,
  file_path TEXT NOT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_asset_video
    FOREIGN KEY (video_id)
    REFERENCES ai_videos(video_id)
    ON DELETE CASCADE
);

-- =========================
-- AI Prompt Precheck Logs
-- (LLM 사전 검증 차단 로그)
-- =========================
CREATE TABLE IF NOT EXISTS ai_prompt_precheck_logs (
  log_id BIGSERIAL PRIMARY KEY,

  user_id VARCHAR(255) NOT NULL,
  prompt TEXT NOT NULL,
  blocked_reason TEXT NOT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Indexes
-- =========================
CREATE INDEX IF NOT EXISTS idx_ai_videos_user_id
  ON ai_videos(user_id);

CREATE INDEX IF NOT EXISTS idx_ai_videos_status
  ON ai_videos(status);

CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_video_id
  ON ai_video_jobs(video_id);

CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_status
  ON ai_video_jobs(status);

CREATE INDEX IF NOT EXISTS idx_precheck_logs_user_id
  ON ai_prompt_precheck_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_precheck_logs_created_at
  ON ai_prompt_precheck_logs(created_at);