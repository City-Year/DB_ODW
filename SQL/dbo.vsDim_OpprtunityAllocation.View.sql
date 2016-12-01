USE [ODW]
GO
/****** Object:  View [dbo].[vsDim_OpprtunityAllocation]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vsDim_OpprtunityAllocation] AS
( 
	SELECT 
		 ID AS OPPORTUNITYALLOCATION_id
		,Name
		,Location__c
		,General_Accounting_Unit_Name__c
		,Fiscal_Year__c

	FROM ODW..rC_Giving__Opportunity_Allocation__c
	)

GO
