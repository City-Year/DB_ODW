USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[uspRealtionship]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspRealtionship]
@Category NVARCHAR(2000),
@Role1 NVARCHAR(2000),
@Role2 NVARCHAR(2000)

AS
BEGIN
SELECT * INTO #Account_Account FROM
(SELECT DISTINCT
	 A.Account1
	,B.Account2
	,A.AccountName1
	,B.AccountName2
	,A.Relationship
	,A.Recordtype  
	,A.Role1
	,A.Role2
FROM
	(
			SELECT 
						 RSHP.rC_Bios__Account_1__c AS Account1
						,RSHP.rC_Bios__Account_2__c AS Account2
						,CASE
							WHEN ACCT.ID=RSHP.rC_Bios__Account_1__c THEN ACCT.Name END AS AccountName1
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Account ACCT 
					RIGHT JOIN Relationship RSHP ON  ACCT.ID=RSHP.rC_Bios__Account_1__c --OR ACCT.Id=RSHP.rC_Bios__Account_2__c
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T1IAI' 
	) A
JOIN
	(		SELECT 
					 RSHP.rC_Bios__Account_1__c AS Account1
					,RSHP.rC_Bios__Account_2__c AS Account2
					,CASE
						WHEN ACCT.ID=RSHP.rC_Bios__Account_2__c THEN ACCT.Name END AS AccountName2
					,RTYPE.Name AS Recordtype
					,RSHP.rC_Bios__Category__c AS Relationship
					,RSHP.rC_Bios__Role_1__c AS Role1
					,RSHP.rC_Bios__Role_2__c AS Role2
				 FROM Account ACCT 
				RIGHT JOIN Relationship RSHP ON  ACCT.ID=RSHP.rC_Bios__Account_2__c --OR ACCT.Id=RSHP.rC_Bios__Account_2__c
				 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
				 WHERE RSHP.RecordTypeId='012U000000013T1IAI' 
	) B ON A.Account1=B.Account1 AND A.Account2=B.Account2
	
	--WHERE A.Relationship in (@Category) AND A.Role1 IN (@Role1) AND A.Role2 IN (@Role2)
	
UNION ALL

SELECT DISTINCT
	 A.Account
	,B.Contact
	,A.AccountName
	,B.ContactName
	,A.Relationship
	,A.Recordtype
	,A.Role1
	,A.Role2
FROM
	(
			SELECT 
						 RSHP.rC_Bios__Account_1__c AS Account
						,RSHP.rC_Bios__Contact_2__c AS Contact
						,CASE
							WHEN ACCT.ID=RSHP.rC_Bios__Account_1__c THEN ACCT.Name END AS AccountName
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Account ACCT 
					RIGHT JOIN Relationship RSHP ON  ACCT.ID=RSHP.rC_Bios__Account_1__c 
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T2IAI' 
					 AND RSHP.rC_Bios__Account_1__c IS NOT NULL AND RSHP.rC_Bios__Contact_2__c IS NOT NULL
	) A
JOIN
	(		SELECT 
						 RSHP.rC_Bios__Account_1__c AS Account
						,RSHP.rC_Bios__Contact_2__c AS Contact
						,CASE
							WHEN CNT.ID=RSHP.rC_Bios__Contact_2__c THEN CNT.Name END AS ContactName
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Contact CNT 
					RIGHT JOIN Relationship RSHP ON  CNT.ID=RSHP.rC_Bios__Contact_2__c 
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T2IAI' 
					 AND RSHP.rC_Bios__Account_1__c IS NOT NULL AND RSHP.rC_Bios__Contact_2__c IS NOT NULL
	) B ON A.Account=B.Account AND A.Contact=B.Contact
	--WHERE A.Relationship in (@Category) AND A.Role1 IN (@Role1) AND A.Role2 IN (@Role2)

UNION ALL

SELECT DISTINCT
	 C.Account
	,D.Contact
	,C.AccountName
	,D.ContactName
	,C.Relationship
	,C.Recordtype
	,C.Role1
	,C.Role2
FROM
(			SELECT 
						RSHP.rC_Bios__Account_2__c AS Account
					,RSHP.rC_Bios__Contact_1__c AS Contact
					,CASE
						WHEN ACCT.ID=RSHP.rC_Bios__Account_2__c THEN ACCT.Name END AS AccountName
					,RTYPE.Name AS Recordtype
					,RSHP.rC_Bios__Category__c AS Relationship
					,RSHP.rC_Bios__Role_1__c AS Role1
					,RSHP.rC_Bios__Role_2__c AS Role2
					FROM Account ACCT 
				RIGHT JOIN Relationship RSHP ON  ACCT.ID=RSHP.rC_Bios__Account_2__c 
					JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					WHERE RSHP.RecordTypeId='012U000000013T2IAI' 
					AND RSHP.rC_Bios__Account_2__c IS NOT NULL AND RSHP.rC_Bios__Contact_1__c IS NOT NULL
	) C
INNER JOIN
	(		SELECT 
						 RSHP.rC_Bios__Account_2__c AS Account
						,RSHP.rC_Bios__Contact_1__c AS Contact
						,CASE
							WHEN CNT.ID=RSHP.rC_Bios__Contact_1__c THEN CNT.Name END AS ContactName
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Contact CNT 
					RIGHT JOIN Relationship RSHP ON  CNT.ID=RSHP.rC_Bios__Contact_1__c 
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T2IAI' 
					 AND RSHP.rC_Bios__Account_2__c IS NOT NULL AND RSHP.rC_Bios__Contact_1__c IS NOT NULL

	) D ON C.Account=D.Account AND C.Contact=D.Contact
	--WHERE C.Relationship IN (@Category) AND C.Role1 IN (@Role1) AND C.Role2 IN (@Role2)
UNION ALL

SELECT DISTINCT
	 A.Contact1
	,B.Contact2
	,A.ContactName1
	,B.ContactName2
	,A.Relationship
	,A.Recordtype
	,A.Role1
	,A.Role2
FROM
	(
			SELECT 
						 RSHP.rC_Bios__Contact_1__c AS Contact1
						,RSHP.rC_Bios__Contact_2__c AS Contact2
						,CASE
							WHEN CNT.ID=RSHP.rC_Bios__Contact_1__c THEN CNT.Name END AS ContactName1
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Contact CNT 
					RIGHT JOIN Relationship RSHP ON  CNT.ID=RSHP.rC_Bios__Contact_1__c 
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T3IAI' 
					 AND RSHP.rC_Bios__Contact_1__c IS NOT NULL AND RSHP.rC_Bios__Contact_2__c IS NOT NULL
	) A
JOIN
	(		SELECT 
						 RSHP.rC_Bios__Contact_1__c AS Contact1
						,RSHP.rC_Bios__Contact_2__c AS Contact2
						,CASE
							WHEN CNT.ID=RSHP.rC_Bios__Contact_2__c THEN CNT.Name END AS ContactName2
						,RTYPE.Name AS Recordtype
						,RSHP.rC_Bios__Category__c AS Relationship
						,RSHP.rC_Bios__Role_1__c AS Role1
						,RSHP.rC_Bios__Role_2__c AS Role2
					 FROM Contact CNT 
					RIGHT JOIN Relationship RSHP ON  CNT.ID=RSHP.rC_Bios__Contact_2__c 
					 JOIN RecordType RTYPE ON RSHP.RecordTypeId=RTYPE.Id
					 WHERE RSHP.RecordTypeId='012U000000013T3IAI' 
					 AND RSHP.rC_Bios__Contact_1__c IS NOT NULL AND RSHP.rC_Bios__Contact_2__c IS NOT NULL

	) B ON A.Contact1=B.Contact1 AND A.Contact2=B.Contact2
--WHERE A.Relationship IN (@Category) AND A.Role1 IN (@Role1) AND A.Role2 IN (@Role2)
) E

CREATE CLUSTERED INDEX IDX_TEMPTBL_ACCT1 ON #Account_Account(Account1)
CREATE  INDEX IDX_TEMPTBL_ACCT2 ON #Account_Account(Account2)
CREATE  INDEX IDX_TEMPTBL_ACCTNAME1 ON #Account_Account(AccountName1)
CREATE  INDEX IDX_TEMPTBL_ACCTNAME2 ON #Account_Account(AccountName2)


SELECT * FROM #Account_Account 
	WHERE Relationship IN (SELECT Value FROM ODW..FnSplit(@Category,',')) 
		AND Role1 IN (SELECT Value FROM ODW..FnSplit(@Role1,','))
		AND Role2 IN (SELECT Value FROM ODW..FnSplit(@Role2,','))
END

GO
