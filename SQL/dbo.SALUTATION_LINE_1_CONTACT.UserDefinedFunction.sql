USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_1_CONTACT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SALUTATION_LINE_1_CONTACT](@CONTACTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(255)

BEGIN
     DECLARE @SAL_LINE_1 VARCHAR(255);

          select TOP 1 @SAL_LINE_1 = salutation_line_1
            from
            (
            SELECT '2' ordernumber, replace(
                      concat(
                          case when len(c.salutation)>1               then (concat(c.salutation, ' '))              else '' end,
                          case when len(c.firstname) >1               then (concat(c.firstname, ' '))               else '' end,
                          case when len(c.rc_bios__middle_name__C) >1 then (concat(c.rc_bios__middle_name__C, ' ')) else '' end,
                          case when len(c.lastname) >1                then (concat(c.lastname, ' '))                else '' end,
                          case when len(c.rc_bios__suffix__C) >1      then (concat(c.rc_bios__suffix__C, ' '))      else '' end),
                      ',',
                      ' ') salutation_line_1
              FROM contact c
             WHERE ID = @CONTACTID_IN
            UNION
            SELECT '1', rc_bios__salutation_line_1__C
              FROM rc_bios__salutation__C
             WHERE rc_bios__contact__C = @CONTACTID_IN
               AND RC_BIOS__SALUTATION_TYPE__C = @SALUTATION_TYPE_IN) Q
             order by Q.ordernumber;
     RETURN @SAL_LINE_1;
    END;

GO
