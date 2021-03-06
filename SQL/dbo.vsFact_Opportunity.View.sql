USE [ODW]
GO
/****** Object:  View [dbo].[vsFact_Opportunity]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vsFact_Opportunity] AS 
(
	SELECT 
		 Id AS OPPORTUNITY_ID
		,AccountId
		,CampaignId
		,CAST(CONVERT(nvarchar(15),CloseDate,112) AS int) DateKey
		,Amount
	
	FROM ODW..Opportunity 
			WHERE DATEPART(YYYY,CloseDate) BETWEEN 1990 AND 2020
		)


GO
