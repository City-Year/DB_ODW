USE [ODW]
GO
/****** Object:  View [dbo].[vsDim_Contact]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vsDim_Contact] AS
(
	SELECT distinct
		 CNT.ID AS CONTACT_ID
		,CNT.Name
		,CNT.Phone
		,CNT.HomePhone
		,CNT.Email
		,CNT.Fax
		,CNT.MailingStreet
		,CNT.MailingCity
		,CNT.MailingState
		,CNT.MailingCountry
		,CNT.MailingPostalCode
		,RCDT.Name AS ContactRecordType
		
	FROM ODW..Contact CNT
	LEFT OUTER JOIN ODW..RecordType RCDT ON CNT.RecordTypeId=RCDT.Id
	)

GO
