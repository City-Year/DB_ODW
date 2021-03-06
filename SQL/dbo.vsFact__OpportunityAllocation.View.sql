USE [ODW]
GO
/****** Object:  View [dbo].[vsFact__OpportunityAllocation]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vsFact__OpportunityAllocation] AS
(
	SELECT 
		 A.ID AS OPPORTUNITYALLOCATION_id
		,A.rC_Giving__Opportunity__c
		,B.AccountId
		,B.CampaignId
		,A.rC_Giving__GAU__c
		,CAST(CONVERT(nvarchar(15),A.rC_Giving__Opportunity_Close_Date__c,112) AS int) DateKey
		,A.rC_Giving__Amount__c

	FROM ODW..rC_Giving__Opportunity_Allocation__c A
	LEFT OUTER JOIN ODW..Opportunity B ON A.rC_Giving__Opportunity__c=B.Id
		WHERE DATEPART(YYYY,rC_Giving__Opportunity_Close_Date__c) BETWEEN 1990 AND 2020 AND A.rC_Giving__Opportunity__c IN (SELECT DISTINCT ID FROM ODW..Opportunity)
	) 


GO
