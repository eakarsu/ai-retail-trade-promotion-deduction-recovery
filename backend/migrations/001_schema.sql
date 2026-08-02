CREATE TABLE IF NOT EXISTS app_users(
  id BIGSERIAL PRIMARY KEY,email TEXT UNIQUE NOT NULL,name TEXT NOT NULL,role TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS workflow_cases(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,reference TEXT UNIQUE NOT NULL,subject TEXT NOT NULL,owner TEXT NOT NULL,state TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,payload JSONB NOT NULL DEFAULT '{}'::jsonb,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS audit_events(
  id BIGSERIAL PRIMARY KEY,event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),actor TEXT NOT NULL,action TEXT NOT NULL,object_type TEXT NOT NULL,object_reference TEXT NOT NULL,detail TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS saved_analyses(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,actor TEXT NOT NULL,analysis_type TEXT NOT NULL,inputs JSONB NOT NULL,result JSONB NOT NULL,provider TEXT NOT NULL,model TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS integration_state(
  id TEXT PRIMARY KEY,name TEXT NOT NULL,category TEXT NOT NULL,mode TEXT NOT NULL,status TEXT NOT NULL,last_tested TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_workflow ON workflow_cases(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_due ON workflow_cases(due_date);
CREATE INDEX IF NOT EXISTS idx_audit_events_time ON audit_events(event_time DESC);

CREATE TABLE IF NOT EXISTS "op_promotion"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_retailer" TEXT NOT NULL,
  "data_promotion" TEXT NOT NULL,
  "data_startDate" DATE NOT NULL,
  "data_funding" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_promotion_due ON "op_promotion"(due_date);

CREATE TABLE IF NOT EXISTS "op_accrual"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_promotion" TEXT NOT NULL,
  "data_period" TEXT NOT NULL,
  "data_accruedAmount" NUMERIC(16,2) NOT NULL,
  "data_expectedAmount" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_accrual_due ON "op_accrual"(due_date);

CREATE TABLE IF NOT EXISTS "op_deduction"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_deductionId" TEXT NOT NULL,
  "data_retailer" TEXT NOT NULL,
  "data_reasonCode" TEXT NOT NULL,
  "data_deductionAmount" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_deduction_due ON "op_deduction"(due_date);

CREATE TABLE IF NOT EXISTS "op_proof"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_promotion" TEXT NOT NULL,
  "data_evidenceType" TEXT NOT NULL,
  "data_storeCount" NUMERIC(16,2) NOT NULL,
  "data_evidenceNotes" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_proof_due ON "op_proof"(due_date);

CREATE TABLE IF NOT EXISTS "op_claim"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_deductionId" TEXT NOT NULL,
  "data_invalidAmount" NUMERIC(16,2) NOT NULL,
  "data_claimBasis" TEXT NOT NULL,
  "data_responseDue" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_claim_due ON "op_claim"(due_date);

CREATE TABLE IF NOT EXISTS "op_forecast"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_promotion" TEXT NOT NULL,
  "data_baselineSales" NUMERIC(16,2) NOT NULL,
  "data_expectedLift" NUMERIC(16,2) NOT NULL,
  "data_funding" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_forecast_due ON "op_forecast"(due_date);

CREATE TABLE IF NOT EXISTS "op_settlement"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_claimId" TEXT NOT NULL,
  "data_retailer" TEXT NOT NULL,
  "data_claimedAmount" NUMERIC(16,2) NOT NULL,
  "data_settledAmount" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_settlement_due ON "op_settlement"(due_date);

CREATE TABLE IF NOT EXISTS "op_post_event"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_promotion" TEXT NOT NULL,
  "data_actualSales" NUMERIC(16,2) NOT NULL,
  "data_actualSpend" NUMERIC(16,2) NOT NULL,
  "data_learning" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_post_event_due ON "op_post_event"(due_date);

CREATE TABLE IF NOT EXISTS "op_retailer_master"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_retailer" TEXT NOT NULL,
  "data_banner" TEXT NOT NULL,
  "data_paymentTerms" TEXT NOT NULL,
  "data_accountOwner" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_retailer_master_due ON "op_retailer_master"(due_date);

CREATE TABLE IF NOT EXISTS "op_sku_master"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_sku" TEXT NOT NULL,
  "data_product" TEXT NOT NULL,
  "data_brand" TEXT NOT NULL,
  "data_listPrice" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_sku_master_due ON "op_sku_master"(due_date);

CREATE TABLE IF NOT EXISTS "op_promotion_calendar"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_event" TEXT NOT NULL,
  "data_retailer" TEXT NOT NULL,
  "data_startDate" DATE NOT NULL,
  "data_plannedFunding" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_promotion_calendar_due ON "op_promotion_calendar"(due_date);

CREATE TABLE IF NOT EXISTS "op_deduction_library"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_retailer" TEXT NOT NULL,
  "data_reasonCode" TEXT NOT NULL,
  "data_disputeDays" NUMERIC(16,2) NOT NULL,
  "data_requiredDocuments" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_deduction_library_due ON "op_deduction_library"(due_date);
