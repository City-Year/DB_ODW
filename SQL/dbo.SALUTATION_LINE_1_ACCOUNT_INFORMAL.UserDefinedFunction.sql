USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_1_ACCOUNT_INFORMAL]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SALUTATION_LINE_1_ACCOUNT_INFORMAL](@ACCOUNTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(255)
BEGIN
     DECLARE @SAL_LINE_1 VARCHAR(255);

          select  TOP 1 @SAL_LINE_1 = salutation_line_1
            from
            (
            SELECT '2' as ordernumber,   case 
                          -- has first name and one contact
                            when V_CONTACT_PRIMARY.FirstName is not null and V_CONTACT_SECONDARY.FirstName is null
                              then CONCAT(V_CONTACT_PRIMARY.FIRSTNAME, ' ', V_CONTACT_PRIMARY.LASTNAME)
                          -- both have first names and last names are different
                            when V_CONTACT_PRIMARY.FIRSTNAME is not null and V_CONTACT_SECONDARY.FIRSTNAME is not null and v_contact_secondary.LASTNAME <> v_contact_primary.LASTNAME
                             then concat(V_CONTACT_PRIMARY.FIRSTNAME, ' ', V_CONTACT_PRIMARY.LASTNAME,' and ', v_contact_secondary.FIRSTNAME, ' ', V_CONTACT_SECONDARY.LASTNAME)
                          -- has first name
                            when V_CONTACT_PRIMARY.FirstName is not null and V_CONTACT_SECONDARY.FirstName is not null
                              then concat(V_CONTACT_PRIMARY.FIRSTNAME, ' and ', v_contact_SECONDARY.FIRSTNAME, ' ', V_CONTACT_PRIMARY.LASTNAME)
                          -- no title and no secondary contact
                            when V_CONTACT_PRIMARY.SALUTATION is null and V_CONTACT_SECONDARY.ID is null
                              then ISNULL(V_CONTACT_PRIMARY.FIRSTNAME, 'Friend')
                          -- both titles null and with secondary contact
                             when V_CONTACT_PRIMARY.SALUTATION is null and V_CONTACT_SECONDARY.SALUTATION is null and V_CONTACT_SECONDARY.ID is not null AND V_CONTACT_SECONDARY.LASTNAME = V_CONTACT_PRIMARY.LASTNAME
                              then concat(ISNULL(V_CONTACT_PRIMARY.FIRSTNAME, 'Friend'),' and ', ISNULL(CONCAT(V_CONTACT_SECONDARY.FIRSTNAME, ' ', V_CONTACT_SECONDARY.LASTNAME), 'Friend'))
                          -- both have titles and last names the same
                            when V_CONTACT_PRIMARY.SALUTATION is not null and V_CONTACT_SECONDARY.SALUTATION is not null and v_contact_secondary.LASTNAME = v_contact_primary.LASTNAME
                              then concat(V_CONTACT_PRIMARY.SALUTATION, ' and ', V_CONTACT_SECONDARY.SALUTATION, ' ',v_contact_PRIMARY.LASTNAME)
                          -- both have titles and last names are different
                            when V_CONTACT_PRIMARY.SALUTATION is not null and V_CONTACT_SECONDARY.SALUTATION is not null and v_contact_secondary.LASTNAME <> v_contact_primary.LASTNAME
                             then concat(V_CONTACT_PRIMARY.SALUTATION, ' ', V_CONTACT_PRIMARY.LASTNAME,' and ', v_contact_secondary.SALUTATION, ' ', V_CONTACT_SECONDARY.LASTNAME)
                          -- has title no secondary contact
                           when V_CONTACT_PRIMARY.SALUTATION is NOT null and V_CONTACT_SECONDARY.ID is null
                              then CONCAT(V_CONTACT_PRIMARY.SALUTATION, ' ' , v_contact_primary.LASTNAME)
                           -- mismatch on title
                            when v_contact_primary.SALUTATION is not null and v_contact_SECONDARY.SALUTATION is null and v_contact_secondary.FIRSTNAME is not null
                             then concat( v_contact_PRIMARY.FIRSTNAME,' and ', v_contact_secondary.FIRSTNAME)
                          when v_contact_primary.SALUTATION is null and v_contact_SECONDARY.SALUTATION is NOT null and v_contact_secondary.FIRSTNAME is not null
                             then concat( v_contact_PRIMARY.FIRSTNAME,' and ', v_contact_secondary.FIRSTNAME)
                            end as salutation_line_1
             FROM  account AS V_ACCOUNT
                   LEFT JOIN contact v_contact_primary 
                          ON 
                                 v_account.ID = v_contact_primary.ACCOUNTID 
                             AND v_contact_primary.id =  DBO.CONTACT_PRIMARY_GUID(v_account.ID)
                   LEFT JOIN contact v_contact_secondary 
                          ON 
                                 v_account.ID = v_contact_secondary.ACCOUNTID 
                             AND v_contact_secondary.ID = DBO.CONTACT_SECONDARY_GUID(v_account.ID)
              where v_account.ID = @ACCOUNTID_IN
            UNION
            SELECT '1', rc_bios__salutation_line_1__C
              FROM rc_bios__salutation__C
             WHERE rc_bios__ACCOUNT__C = @ACCOUNTID_IN
               AND RC_BIOS__SALUTATION_TYPE__C = @SALUTATION_TYPE_IN)q
             order by Q.ordernumber
     RETURN @SAL_LINE_1;
    END;

GO
