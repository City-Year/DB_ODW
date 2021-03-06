USE [ODW]
GO
/****** Object:  View [dbo].[vsDim_Account]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vsDim_Account] as
(
	SELECT 
	 A.ACCOUNT_ID
	,A.Name
	,A.Type
	,A.BillingCity
	,A.BillingCountry
	,A.BillingPostalCode
	,A.BillingState
	,A.BillingStreet 
	,A.AccountRecordType
	,CASE
		WHEN A.FirstContributionDate<=ISNULL(B.FirstContributionDate,DATEADD(YYYY,200,GETDATE())) THEN A.FirstContributionDate
		WHEN B.FirstContributionDate<=ISNULL(A.FirstContributionDate,DATEADD(YYYY,200,GETDATE()) )THEN B.FirstContributionDate 
		--ELSE B.FirstContributionDate 
		END AS FirstContributionDate 
	,CASE
		WHEN A.LastContributionDate>=ISNULL(B.LastContributionDate,DATEADD(YYYY,-200,GETDATE())) THEN A.LastContributionDate
		WHEN B.LastContributionDate>=ISNULL(A.LastContributionDate,DATEADD(YYYY,-200,GETDATE())) THEN B.LastContributionDate 
		--ELSE B.LastContributionDate 
		END AS LastContributionDate 
	,K.LowestContributionDate
	,K.HighestContributionDate
	
FROM	
	(SELECT DISTINCT
				 ACCT.ID AS ACCOUNT_ID
				,ACCT.Name
				,ACCT.Type
				,ACCT.BillingStreet
				,ACCT.BillingCity
				,ACCT.BillingState
				,ACCT.BillingCountry
				,ACCT.BillingPostalCode
				,RCDT.Name AS AccountRecordType
				, OPT.Lastdate  AS LastContributionDate
				, OPT.Firstdate  AS FirstContributionDate
		FROM ODW..Account ACCT
			LEFT OUTER JOIN ODW..RecordType RCDT ON ACCT.RecordTypeId=RCDT.Id
			LEFT OUTER JOIN 
				(SELECT AccountId,MAX(CLOSEDATE) AS Lastdate,MIN(CLOSEDATE) Firstdate FROM ODW..Opportunity OPT
					WHERE RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY')
					GROUP BY AccountID) OPT ON ACCT.Id=OPT.AccountId
		) A
	
LEFT OUTER JOIN

	(SELECT 
			rC_Giving__Account__c  as AccountID
		,MAX([rC_Giving__Opportunity_Close_Date__c] ) AS LastContributionDate
		,MIN([rC_Giving__Opportunity_Close_Date__c] ) AS FirstContributionDate
	FROM ODW..[rC_Giving__Opportunity_Credit__c] CRDT
	GROUP BY rC_Giving__Account__c
	) B ON A.ACCOUNT_ID=B.AccountID

LEFT OUTER JOIN

	(SELECT
		 ISNULL(I.AccountId,J.AccountID) AccountId
		,CASE 
			WHEN ISNULL(I.LowestAmount,J.LowestAmount)>=J.LowestAmount THEN J.LowestContributionDate
			WHEN ISNULL(I.LowestAmount,J.LowestAmount)<=ISNULL(J.LowestAmount,I.LowestAmount) THEN I.LowestContributionDate 
			END AS LowestContributionDate
		,CASE 
			WHEN ISNULL(I.HighestAmount,J.HighestAmount)<=J.HighestAmount THEN J.HighestContributionDate
			WHEN ISNULL(I.HighestAmount,J.HighestAmount)>=ISNULL(J.HighestAmount,I.HighestAmount) THEN I.HighestContributionDate 
			END AS HighestContributionDate
FROM
(SELECT
		 C.AccountId
		,C.HighestAmount
		,C.LowestAmount
		,D.HighestContributionDate
		,E.LowestContributionDate
	FROM
		(SELECT	
			AccountId
			,MAX(Amount) AS HighestAmount
			,MIN(Amount) AS LowestAmount
   
		FROM ODW..Opportunity OPT
		WHERE RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY')
		GROUP BY AccountID
		) C
		LEFT OUTER JOIN
		(SELECT 
				Accountid
			,MAX(CloseDate) AS HighestContributionDate
		FROM Opportunity 
		WHERE CAST(Amount AS nvarchar(50))+'_'+AccountId IN
			(SELECT CAST(MAX(amount) as nvarchar(50))+'_'+AccountId FROM Opportunity 
			WHERE RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY') 
			GROUP BY AccountId)
			AND RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY')
			group  by AccountId
			) D ON C.AccountId=D.AccountId
 
		LEFT OUTER JOIN
		(SELECT 
				Accountid
			,MAX(CloseDate) AS LowestContributionDate
		FROM Opportunity 
		WHERE CAST(Amount AS nvarchar(50))+'_'+AccountId IN
			(SELECT CAST(MIN(amount) as nvarchar(50))+'_'+AccountId FROM Opportunity 
			WHERE RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY') 
			GROUP BY AccountId)
			AND RecordTypeId IN ('012U000000017QSIAY','012U000000017QXIAY')
			group  by AccountId
			) E ON C.AccountId=E.AccountId
	) I 
	--ON A.ACCOUNT_ID=I.AccountId

FULL  JOIN

	(SELECT
			 F.AccountID
			,F.HighestAmount
			,F.LowestAmount
			,G.HighestContributionDate
			,H.LowestContributionDate
		 FROM
			(SELECT 
				 rC_Giving__Account__c  as AccountID
				,MAX(rC_Giving__Amount__c ) AS HighestAmount
				,MIN(rC_Giving__Amount__c) AS LowestAmount
			 FROM ODW..[rC_Giving__Opportunity_Credit__c]
			 GROUP BY rC_Giving__Account__c
			) F
		LEFT OUTER JOIN 
			(SELECT
				 rC_Giving__Account__c AS AccountID
				,MAX(rC_Giving__Opportunity_Close_Date__c) AS HighestContributionDate
			 FROM ODW..rC_Giving__Opportunity_Credit__c
			 WHERE CAST(rC_Giving__Amount__c AS NVARCHAR(50))+'_'+rC_Giving__Account__c IN 
					(SELECT CAST(MAX(rC_Giving__Amount__c) AS NVARCHAR(50))+'_'+rC_Giving__Account__c 
					 FROM ODW..rC_Giving__Opportunity_Credit__c 
					 GROUP BY rC_Giving__Account__c)
			 GROUP BY rC_Giving__Account__c
			 ) G ON F.AccountID=G.AccountID
		LEFT OUTER JOIN 
			(SELECT
				 rC_Giving__Account__c AS AccountID
				,MAX(rC_Giving__Opportunity_Close_Date__c) AS LowestContributionDate
			 FROM ODW..rC_Giving__Opportunity_Credit__c
			 WHERE CAST(rC_Giving__Amount__c AS NVARCHAR(50))+'_'+rC_Giving__Account__c IN 
					(SELECT CAST(MIN(rC_Giving__Amount__c) AS NVARCHAR(50))+'_'+rC_Giving__Account__c 
					 FROM ODW..rC_Giving__Opportunity_Credit__c 
					 GROUP BY rC_Giving__Account__c)
			 GROUP BY rC_Giving__Account__c
			  ) H ON F.AccountID=H.AccountID
			 --where F.AccountID='001U000000fXg5YIAS'
) J on I.AccountId=J.AccountID
) K ON A.ACCOUNT_ID=K.AccountId
	)


GO
