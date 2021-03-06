USE [ODW]
GO
/****** Object:  View [dbo].[S_PREFERRED_ADDRESS_BILLING]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[S_PREFERRED_ADDRESS_BILLING]
AS 
SELECT * 
  FROM RC_BIOS__ACCOUNT_ADDRESS__C 
 WHERE RC_BIOS__PREFERRED_BILLING__C  = 1
   AND RC_BIOS__DO_NOT_MAIL__C <> 1 
   AND RC_BIOS__UNDELIVERABLE_COUNT__C < 3;
GO
