USE [ODW]
GO
/****** Object:  View [dbo].[vsDim_Opportunity]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vsDim_Opportunity] AS 
(
	SELECT 
		 OPT.ID AS OpportunityID
		,OPT.AccountId
		,OPT.CampaignId
		,OPT.Name AS OpportunityName
		,OPT.StageName
		,OPT.IsWon
		,OPT.IsClosed
		,OPT.ForecastCategory
		,RCDT.Name AS OpportuityRecordType
		,OPT.Amount
		,OPT.CloseDate
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2014 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2014 THEN 'N' 
			ELSE 'N' END AS Donated_in_2014
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2013 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2013 THEN 'N' 
			ELSE 'N' END AS Donated_in_2013
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2012 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2012 THEN 'N' 
			ELSE 'N' END AS Donated_in_2012
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2011 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2011 THEN 'N' 
			ELSE 'N' END AS Donated_in_2011
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2010 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2010 THEN 'N' 
			ELSE 'N' END AS Donated_in_2010
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2009 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2009 THEN 'N' 
			ELSE 'N' END AS Donated_in_2009
		,CASE WHEN OPT.Amount > 0 AND YEAR(OPT.CloseDate)=2008 THEN 'Y'
			WHEN OPT.Amount <= 0 AND YEAR(OPT.CloseDate)=2008 THEN 'N' 
			ELSE 'N' END AS Donated_in_2008
	FROM ODW..Opportunity OPT
	LEFT OUTER JOIN ODW..RecordType RCDT ON OPT.RecordTypeId=RCDT.Id
	)

GO
