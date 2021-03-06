USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_INSIDE_CONTACT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SALUTATION_INSIDE_CONTACT](@CONTACTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) 
RETURNS varchar(255)

AS
BEGIN
     DECLARE @SAL_LINE_1 VARCHAR(255);
          SELECT TOP 1 @SAL_LINE_1 = Q.inside_salutation
          FROM
          (
          SELECT '2' ordernumber, replace(
                    CASE
                       WHEN a.SALUTATION IS NOT NULL
                       THEN
                          concat(a.SALUTATION, ' ', a.LASTNAME)
                       ELSE
                          A.FIRSTNAME
                    END,
                    ',',
                    ' ') as inside_salutation
            FROM contact a
           WHERE ID = @CONTACTID_IN
          UNION
          SELECT '1' as ordernumber, replace(rc_bios__inside_salutation__c,',',' ') inside_salutation
            FROM rc_bios__salutation__c
           WHERE rc_bios__contact__c = @CONTACTID_IN
             AND RC_BIOS__SALUTATION_TYPE__c = @SALUTATION_TYPE_IN) Q
           ORDER BY Q.ordernumber;
     RETURN @SAL_LINE_1;
END;


GO
