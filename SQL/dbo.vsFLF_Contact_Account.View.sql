USE [ODW]
GO
/****** Object:  View [dbo].[vsFLF_Contact_Account]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW  [dbo].[vsFLF_Contact_Account] AS
(
select  row_number() over (order by a.id) S_Key,A.ID contactid,B.Id AccountId from ODW..Contact A
JOIN ODW..Account B  ON A.AccountId=b.id
)

GO
