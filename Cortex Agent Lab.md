# Build a Cortex Agent from Scratch — Simplified

This hands-on lab walks you through building a Cortex Agent that answers natural language questions about structured sales data. You will:

1. Set up the environment and load sample data (SQL)
2. Create a Semantic View using the Snowsight AI-assisted wizard
3. Create a Cortex Agent and attach the Semantic View
4. Test the Agent through Snowflake Intelligence

**Time to complete:** ~30 minutes  
**Prerequisites:** A Snowflake account with `ACCOUNTADMIN` access

---

## Step 1: Run the Setup SQL

Open Project -> Workspaces.  Click **+ Add new** > **SQL file** and name it `setup.sql`

Copy all the contents of `01_setup_and_data.sql`, edit row 14 to replace `<YOUR USERNAME>` with your own and choose **Run all** (the arrow beside the play button) . 

This script:
- Enables cross-region inference (required for Cortex AI model access)
- Creates a custom role `SANOFI_AGENT` and grants it to your user (all objects will be owned by this role, not ACCOUNTADMIN)
- Switches to the `SANOFI_AGENT` role, then creates a dedicated warehouse (`CORTEX_AGENT_LAB_WH`), database (`CORTEX_AGENT_LAB`), and schema (`TUTORIAL`)
- Creates and populates a **products** table (8 Sanofi drugs) and a **sales** table (18 transactions) joined by `product_id`
- Runs a quick Cortex AI verification query

> **Note:** After running this script, use the `SANOFI_AGENT` role for all remaining steps in this lab. You can switch roles in Snowsight by clicking your user name in the bottom-left corner and selecting `SANOFI_AGENT`.

After running, confirm you see:

| table_name | row_count |
|---|---|
| products | 8 |
| sales | 18 |

---

## Step 2: Create the Semantic View 

The Semantic View defines the business meaning of your sales data so the agent can translate natural language into SQL.

1. From the bottom left (circle initial icon), switch the role to `SANOFI_AGENT` 
2. Navigate to **AI & ML** > **Analyst** in the left sidebar
2. Under Semantic views, choose database `CORTEX_AGENT_LAB` and schema `TUTORIAL`
3. Click **Create with Autopilot** (top right)
   - **Provide context** click Skip (bottom right) and click Next
   - **Name your semantic view** `SALES_SEMANTIC_VIEW` and click Next

### Select Tables

4. Select both tables:
   - **CORTEX_AGENT_LAB.TUTORIAL.PRODUCTS**
   - **CORTEX_AGENT_LAB.TUTORIAL.SALES**
6. Click **Next**

### Select Columns

7. From the **PRODUCTS** table, select all columns.

8. From the **SALES** table, select all columns:

9. Click **Create**

### Provide Context (Optional)

On the right hand side, you can click **Add a verified query**, which will help the AI understand your data:

**Question:** What is total revenue by therapeutic area?
```sql
SELECT p.therapeutic_area, SUM(s.revenue_usd) AS total_revenue FROM CORTEX_AGENT_LAB.TUTORIAL.SALES s JOIN CORTEX_AGENT_LAB.TUTORIAL.PRODUCTS p ON s.product_id = p.product_id GROUP BY p.therapeutic_area ORDER BY total_revenue DESC
```

**Question:** Which product has the highest revenue?
```sql
SELECT p.product_name, SUM(s.revenue_usd) AS total_revenue FROM CORTEX_AGENT_LAB.TUTORIAL.SALES s JOIN CORTEX_AGENT_LAB.TUTORIAL.PRODUCTS p ON s.product_id = p.product_id GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 1
```

10. Click **Save** (top right)

### Review and Refine (Optional)

After generation completes, you can review:
- **Dimensions** (the categorical columns like region, category, product_name)
- **Metrics** (aggregations like SUM of total_amount, COUNT of transactions)
- **Verified Queries** (the example queries you provided)

Make adjustments if needed, then **Save**.

---

## Step 3: Create the Cortex Agent and Attach the Semantic View

Now create the agent and wire it to the Semantic View you just built.

### Create the Agent

1. In Snowsight, navigate to **AI & ML** > **Agents** in the left sidebar
2. Click **Create agent**
3. Configure:
   - **Database:** `CORTEX_AGENT_LAB`
   - **Schema:** `TUTORIAL`
   - **Agent object name:** `SALES_AGENT` (leave Display name unchanged)
4. Click **Create agent**

### Add the Cortex Analyst Tool

5. Select the **Tools** tab
6. Find **Cortex Analyst** and click **+ Add** > **Add semantic view**
7. Configure:
   - From the pulldown menu, choose `CORTEX_AGENT_LAB.TUTORIAL.SALES_SEMANTIC_VIEW`
   - **Name:** `SalesAnalyst`
   - **Description:** `Queries structured sales data by converting natural language to SQL`
   - Click **Add** 

### Configure Orchestration

8. Select the **Orchestration** tab
9. Set the following:
    - **Orchestration model:** `auto` (or select other models)
    - **Orchestration instructions:** `Use the SalesAnalyst tool for any question about pharmaceutical sales, revenue, products, therapeutic areas, regions, or distribution channels.`
    - **Response instruction:** `Be concise and include relevant numbers. Present data in tables when appropriate.`
10. Click **Save** (top right)
11. Test a query on the right hand side.  `What is total revenue by therapeutic area?`

---

## Step 4: Test with Snowflake Intelligence

1. From the `SALES_AGENT` view, click on **Preview in Snowflake Intelligence** (top right)
2. In the chat bar at the bottom, click the agent picker (may say "General purpose")
3. Select **SALES_AGENT** from the list
4. Try these questions:

### Sample Questions

| Question | What it tests |
|---|---|
| What is total revenue by therapeutic area? | Join + aggregation + grouping |
| Which product has the highest revenue? | Sorting + limiting |
| How many units of Dupixent were sold? | Filtering by product |
| Show me revenue by distribution channel | Grouping by channel |
| What are total sales in Europe? | Filtering by region |
| Compare Immunology vs Diabetes revenue | Therapeutic area comparison |

### Multi-turn Conversation

Try a follow-up to test context retention:
1. Ask: "What is total revenue by region?"
2. Follow up: "Which region had the lowest?"

The agent should remember the context from your first question.

---

## Summary

| What you built | Purpose |
|---|---|
| Products table | 8 Sanofi drugs with therapeutic area and formulation |
| Sales table | 18 transactions joined to products by product_id |
| Semantic View | Maps business terms to SQL (enables natural language queries) |
| Cortex Agent | Orchestrates questions → SQL → answers automatically |

**Next steps:** Add more verified queries, extend with additional tables, or explore adding a Cortex Search service for unstructured document retrieval.
