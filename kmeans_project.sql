-- 1. Members Dimension
CREATE TABLE kmeans.dim_members (
    member_id UUID PRIMARY KEY,
    onboarding_date DATE NOT NULL,
    member_type VARCHAR(20) CHECK (member_type IN ('Individual', 'Corporate')),
    credit_score_internal INT CHECK (credit_score_internal BETWEEN 0 AND 1000),
    central_bank_rating CHAR(1) -- e.g., BCB rating (A, B, C, D...)
)

-- 2. Credit Products Dimension (The 7 Credit Products)
CREATE TABLE kmeans.dim_credit_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL, -- e.g., Personal Loan, Credit Card, Overdraft, Agribusiness Credit
    product_category VARCHAR(30),
    funding_cost_rate DECIMAL(5,4) -- Internal cost of capital
)

-- 3. Credit Operations Fact Table (Granular Loan Level)
CREATE TABLE kmeans.fact_credit_operations (
    operation_id UUID PRIMARY KEY,
    member_id UUID REFERENCES kmeans.dim_members(member_id),
    product_id INT REFERENCES kmeans.dim_credit_products(product_id),
    origination_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    contracted_amount DECIMAL(15,2) NOT NULL,
    outstanding_balance DECIMAL(15,2) NOT NULL,
    nominal_interest_rate DECIMAL(5,4) NOT NULL, -- Average interest rate parameter
    -- Operational Friction Metrics
    operational_tat_hours INT, -- Time of operation to run / Time to Turn Around (TAT)
    customer_acquisition_cost DECIMAL(10,2),    
    -- Status and Risk
    days_past_due INT DEFAULT 0, -- Inadimplency tracker
    provision_for_credit_loss DECIMAL(15,2) -- Risk mitigation value
)

-- 4. Product Usage and Transactional Fact Table
CREATE TABLE kmeans.fact_product_usage_monthly (
    snapshot_month DATE NOT NULL,
    member_id UUID REFERENCES kmeans.dim_members(member_id),
    product_id INT REFERENCES kmeans.dim_credit_products(product_id),
    total_limit DECIMAL(15,2),
    utilized_limit_avg DECIMAL(15,2),
    payment_delay_frequency DECIMAL(4,3), -- Payback/punctuality metric
    total_interest_paid DECIMAL(15,2),
    PRIMARY KEY (snapshot_month, member_id, product_id)
)



-- SELECT AREA
select * from kmeans.dim_credit_products

SELECT * FROM kmeans.dm_clustering_credit_users 