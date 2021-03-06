USE [ODW]
GO
/****** Object:  View [dbo].[vsDim_Campaign]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vsDim_Campaign] as
(
	SELECT 
		 A.Id AS Campaign_ID
		,A.Name AS CampaignName
		,B.Name AS RecordType
		,A.Status
		,A.Description
		,A.Location__c
		,A.Fiscal_Year__c
		
	FROM ODW..Campaign A
	LEFT OUTER JOIN ODW..RecordType B ON A.RecordTypeId=B.Id
	)

GO
