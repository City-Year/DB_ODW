USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_3_ACCOUNT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SALUTATION_LINE_3_ACCOUNT](@ACCOUNTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(255)

BEGIN
     DECLARE @SAL_LINE_3 VARCHAR(255);

          select  @SAL_LINE_3 = salutation_line_3
            from
            (
            SELECT '2' ordernumber, replace(
              case when len(a.name)>1 then A.name else NULL end, ',', ' ') salutation_line_3
              FROM account A
              where a.type not in ('Individual', 'Family', 'Prospect')
                and ID = @ACCOUNTID_IN
            UNION
            SELECT '1', rc_bios__salutation_line_3__C
              FROM rc_bios__salutation__C
             WHERE rc_bios__ACCOUNT__C = @ACCOUNTID_IN
               AND RC_BIOS__SALUTATION_TYPE__C = @SALUTATION_TYPE_IN) Q
             order by Q.ordernumber;
     RETURN @SAL_LINE_3;
    END;
GO
