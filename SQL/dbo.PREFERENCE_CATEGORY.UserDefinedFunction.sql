USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[PREFERENCE_CATEGORY]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[PREFERENCE_CATEGORY](@CATEGORY_IN VARCHAR(18))

RETURNS varchar(18)
AS
BEGIN
     DECLARE @RESULT VARCHAR(18);
     SELECT @RESULT = rc_bios__CATEGORY__C
        FROM s_preference_account
       WHERE     isnull(RC_BIOS__START_DATE__C, GETDATE()) >= GETDATE()
             AND isnull(rc_bios__end_date__C, GETDATE()) <= GETDATE()
             AND rc_bios__active__C = 1
             AND rc_bios__category__C = @CATEGORY_IN;
     RETURN @RESULT;
END;

GO
