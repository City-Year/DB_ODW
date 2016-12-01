USE [ODW]
GO
/****** Object:  View [dbo].[vsFact_Soft_Credit]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW  [dbo].[vsFact_Soft_Credit] AS
(
SELECT 
	 OPTCRDT.Id AS CreditID
	,OPTCRDT.rC_Giving__Opportunity__c AS CreditOpportunityId
	,OPTCRDT.rC_Giving__Account__c AS CreditAccountId
	,OPTCRDT.rC_Giving__Contact__c AS CreditContactId
	,OPTCRDT.rC_Giving__Amount__c AS CreditAmount
	

FROM ODW..rC_Giving__Opportunity_Credit__c OPTCRDT

where OPTCRDT.rC_Giving__Account__c not in('001U000000fXXN0IAO')
)








GO
