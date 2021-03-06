USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_3_Populate_Tables]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_3_Populate_Tables]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- RC Bios Address
	insert into ODW.dbo.DimBiosAddress([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],
	[Address Name],[Owner ID],[Archive?],[Block Group],[Block Number],[Carrier Route],[Census Tract],[City],[CMRA],[Congressional District],[Country],[Country Name],[County],
	[County Number],[Delivery Point],[DPV],[DPV Footnote],[Extension],[Extension Number],[External ID],[Firm],[LACS],[Latitude],[Longitude],[Maps],[Maps (Bing Url)],
	[Maps (Google Url)],[Maps (Yahoo Url)],[PMB],[PMB Designator],[Post-Direction],[Postal Code],[Pre-Direction],[State],[State Number],[Street Address],[Street Line 1],
	[Street Line 2],[Street Name],[Street Number],[Street Type],[Unique MD5],[Urbanization],[Village],[ZIP],[ZIP Addon],[ZIP Plus 4],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Archive_Flag__c,
	rC_Bios__Block_Group__c,rC_Bios__Block_Number__c,rC_Bios__Carrier_Route__c,rC_Bios__Census_Tract__c,rC_Bios__City__c,rC_Bios__CMRA__c,rC_Bios__Congressional_District__c,
	rC_Bios__Country__c,rC_Bios__Country_Name__c,rC_Bios__County__c,rC_Bios__County_Number__c,rC_Bios__Delivery_Point__c,rC_Bios__DPV__c,rC_Bios__DPV_Footnote__c,
	rC_Bios__Extension__c,rC_Bios__Extension_Number__c,rC_Bios__External_Id__c,rC_Bios__Firm__c,rC_Bios__LACS__c,rC_Bios__Lat__c,rC_Bios__Lng__c,rC_Bios__Maps__c,
	rC_Bios__Maps_Bing_Url__c,rC_Bios__Maps_Google_Url__c,rC_Bios__Maps_Yahoo_Url__c,rC_Bios__PMB__c,rC_Bios__PMB_Designator__c,rC_Bios__Post_Direction__c,rC_Bios__Postal_Code__c,
	rC_Bios__Pre_Direction__c,rC_Bios__State__c,rC_Bios__State_Number__c,rC_Bios__Street_Address__c,rC_Bios__Street_Line_1__c,rC_Bios__Street_Line_2__c,rC_Bios__Street_Name__c, rC_Bios__Street_Number__c,
	rC_Bios__Street_Type__c,rC_Bios__Unique_MD5__c,rC_Bios__Urbanization__c,rC_Bios__Village__c,rC_Bios__ZIP__c,rC_Bios__ZIP_Addon__c,rC_Bios__ZIP_Plus_4__c, SystemModstamp 
	from ODW_Stage.dbo.rC_Bios__Address__c (nolock)


	-- RC Bios Salutation (Contact)
	insert into ODW.dbo.DimBiosContactSalutation([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Activity Date],[Last Modified By ID],
	[Last Modified Date],[Salutation Name],[Owner ID],[Account],[Archive?],[Contact],[Inside Salutation],[Preferred Salutation?],[Salutation Description],[Salutation Line 1],
	[Salutation Line 2],[Salutation Line 3],[Salutation Type],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Contact__c,rC_Bios__Inside_Salutation__c,rC_Bios__Preferred_Salutation__c,rC_Bios__Salutation_Description__c,rC_Bios__Salutation_Line_1__c,
	rC_Bios__Salutation_Line_2__c,rC_Bios__Salutation_Line_3__c,rC_Bios__Salutation_Type__c,SystemModstamp 
	from ODW_Stage.dbo.rC_Bios__Salutation__c (nolock)
	where rC_Bios__Contact__c is not null


	-- RC Bios Salutation (Account)
	insert into ODW.dbo.DimBiosAccountSalutation([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Activity Date],[Last Modified By ID],
	[Last Modified Date],[Salutation Name],[Owner ID],[Account],[Archive?],[Contact],[Inside Salutation],[Preferred Salutation?],[Salutation Description],[Salutation Line 1],
	[Salutation Line 2],[Salutation Line 3],[Salutation Type],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Contact__c,rC_Bios__Inside_Salutation__c,rC_Bios__Preferred_Salutation__c,rC_Bios__Salutation_Description__c,rC_Bios__Salutation_Line_1__c,
	rC_Bios__Salutation_Line_2__c,rC_Bios__Salutation_Line_3__c,rC_Bios__Salutation_Type__c,SystemModstamp 
	from ODW_Stage.dbo.rC_Bios__Salutation__c (nolock)
	where rC_Bios__Account__c is not null

	
	-- RC Bios Preferences (Account)
	insert into ODW.dbo.DimBiosAccountPreferences([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],
	[Reference #],[Owner ID],[Account],[Active?],[Affiliation],[Archive?],[Availability],[Category],[Code Value],[Comments],[Contact],[End Date],[External ID],[Geography],[Maximum Shift Length],
	[Role],[Skills],[Start Date],[Status],[Subcategory],[Subtype],[Type],[Value],[Record Type ID],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account__c,rC_Bios__Active__c,rC_Bios__Affiliation__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Availability__c,rC_Bios__Category__c,rC_Bios__Code_Value__c,rC_Bios__Comments__c,rC_Bios__Contact__c,rC_Bios__End_Date__c,rC_Bios__External_ID__c,
	rC_Bios__Geography__c,rC_Bios__Maximum_Shift_Length__c,rC_Bios__Role__c,rC_Bios__Skills__c,rC_Bios__Start_Date__c,rC_Bios__Status__c,rC_Bios__Subcategory__c,rC_Bios__Subtype__c,
	rC_Bios__Type__c,rC_Bios__Value__c,RecordTypeId,SystemModstamp 
	from ODW_Stage.dbo.rc__Bios_Preferences (nolock) 
	where rC_Bios__Account__c is not null


	-- RC Bios Preferences (Contact)
	insert into ODW.dbo.DimBiosContactPreferences([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],
	[Reference #],[Owner ID],[Account],[Active?],[Affiliation],[Archive?],[Availability],[Category],[Code Value],[Comments],[Contact],[End Date],[External ID],[Geography],[Maximum Shift Length],
	[Role],[Skills],[Start Date],[Status],[Subcategory],[Subtype],[Type],[Value],[Record Type ID],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account__c,rC_Bios__Active__c,rC_Bios__Affiliation__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Availability__c,rC_Bios__Category__c,rC_Bios__Code_Value__c,rC_Bios__Comments__c,rC_Bios__Contact__c,rC_Bios__End_Date__c,rC_Bios__External_ID__c,
	rC_Bios__Geography__c,rC_Bios__Maximum_Shift_Length__c,rC_Bios__Role__c,rC_Bios__Skills__c,rC_Bios__Start_Date__c,rC_Bios__Status__c,rC_Bios__Subcategory__c,rC_Bios__Subtype__c,
	rC_Bios__Type__c,rC_Bios__Value__c,RecordTypeId,SystemModstamp 
	from ODW_Stage.dbo.rc__Bios_Preferences (nolock) 
	where rC_Bios__Contact__c is not null


	-- Allocation - Hard Credits
	insert into ODW.dbo.DimHardCredit_Allocation([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[External ID],[FFR Key],[Fiscal Year],[General Accounting Unit Name],
	[Giving Amount],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],[Location],[Reference #],[Opportunity: Probability],[Proposal Amount],[Amount],[Archive?],[Comments],
	[Distribution %],[General Accounting Unit],[Fixed?],[Opportunity],[Opportunity: Close Date],[Opportunity: Current Giving Amount],[Opportunity: Stage],[System Modstamp],
	[Weighted Giving Amount],[Weighted Proposal Amount],[60% Weighted Proposal Amount],[90% Weighted Proposal Amount], [Project], [Revenue Category])
	select ConnectionReceivedId, ConnectionSentId,CreatedById,CreatedDate,External_ID__c,FFR_Key__c,Fiscal_Year__c,General_Accounting_Unit_Name__c,Giving_Amount__c,Id,IsDeleted,LastModifiedById,
	LastModifiedDate,Location__c,Name,Opportunity_Probability__c,Proposal_Amount__c,rC_Giving__Amount__c,rC_Giving__Archive_Flag__c,rC_Giving__Comments__c,rC_Giving__Distribution__c,
	rC_Giving__GAU__c,rC_Giving__Is_Fixed__c,rC_Giving__Opportunity__c,rC_Giving__Opportunity_Close_Date__c,rC_Giving__Opportunity_Current_Giving_Amount__c,rC_Giving__Opportunity_Stage__c,
	SystemModstamp,Weighted_Giving_Amount__c,Weighted_Proposal_Amount__c,X60_Weighted_Proposal_Amount__c,X90_Weighted_Proposal_Amount__c, Project__c, Revenue_Category__c
	from ODW_Stage.dbo.rC_Giving__Opportunity_Allocation__c (nolock)


	-- Credit - Soft Credits
	insert into ODW.dbo.DimSoftCredit([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],[Reference #],[Account],[Amount],[Archive?],[Contact],[Contact Role],[Distribution %],[Fixed?],[Opportunity],[Opportunity: Close Date],[Opportunity: Current Giving Amount],[Opportunity: Stage],[Related To],[Type],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,rC_Giving__Account__c,rC_Giving__Amount__c,rC_Giving__Archive_Flag__c,rC_Giving__Contact__c,rC_Giving__Contact_Role__c,rC_Giving__Distribution__c,rC_Giving__Is_Fixed__c,rC_Giving__Opportunity__c,rC_Giving__Opportunity_Close_Date__c,rC_Giving__Opportunity_Current_Giving_Amount__c,rC_Giving__Opportunity_Stage__c,rC_Giving__Related_To__c,rC_Giving__Type__c,SystemModstamp
	from ODW_Stage.dbo.rC_Giving__Opportunity_Credit__c (nolock)


/*
	-- RC Relationship
	insert into ODW.dbo.DimRelationship([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Activity Date],[Last Modified By ID],[Last Modified Date],[Reference #],[Owner ID],[Account From],[Account To],[Active?],[Archive?],[Category],[Comments],[Comments?],[Contact From],[Contact To],[Degree],[Department],[Graduation Year],[Job Title],[Major],[Opportunity],[Position],[Primary?],[Role @Deprecated(Version=2.0)],[Role 1],[Role 2],[Starting Day],[Starting Month],[Starting Year],[Stopping Day],[Stopping Month],[Stopping Year],[Record Type ID],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account_1__c,rC_Bios__Account_2__c,rC_Bios__Active__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Category__c,rC_Bios__Comments__c,rC_Bios__Comments_Flag__c,rC_Bios__Contact_1__c,rC_Bios__Contact_2__c,rC_Bios__Degree__c,rC_Bios__Department__c,rC_Bios__Graduation_Year__c,
	rC_Bios__Job_Title__c,rC_Bios__Major__c,rC_Bios__Opportunity__c,rC_Bios__Position__c,rC_Bios__Primary__c,rC_Bios__Role__c,rC_Bios__Role_1__c,rC_Bios__Role_2__c,rC_Bios__Starting_Day__c,rC_Bios__Starting_Month__c,
	rC_Bios__Starting_Year__c,rC_Bios__Stopping_Day__c,rC_Bios__Stopping_Month__c,rC_Bios__Stopping_Year__c,RecordTypeId,SystemModstamp
	from ODW_Stage.dbo.Relationship (nolock)

	insert into ODW.dbo.DimContactRelationship([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Activity Date],[Last Modified By ID],[Last Modified Date],[Reference #],[Owner ID],[Account From],[Account To],[Active?],[Archive?],[Category],[Comments],[Comments?],[Contact From],[Contact To],[Degree],[Department],[Graduation Year],[Job Title],[Major],[Opportunity],[Position],[Primary?],[Role @Deprecated(Version=2.0)],[Role 1],[Role 2],[Starting Day],[Starting Month],[Starting Year],[Stopping Day],[Stopping Month],[Stopping Year],[Record Type ID],[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account_1__c,rC_Bios__Account_2__c,rC_Bios__Active__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Category__c,rC_Bios__Comments__c,rC_Bios__Comments_Flag__c,rC_Bios__Contact_1__c,rC_Bios__Contact_2__c,rC_Bios__Degree__c,rC_Bios__Department__c,rC_Bios__Graduation_Year__c,
	rC_Bios__Job_Title__c,rC_Bios__Major__c,rC_Bios__Opportunity__c,rC_Bios__Position__c,rC_Bios__Primary__c,rC_Bios__Role__c,rC_Bios__Role_1__c,rC_Bios__Role_2__c,rC_Bios__Starting_Day__c,rC_Bios__Starting_Month__c,
	rC_Bios__Starting_Year__c,rC_Bios__Stopping_Day__c,rC_Bios__Stopping_Month__c,rC_Bios__Stopping_Year__c,RecordTypeId,SystemModstamp
	from ODW_Stage.dbo.Relationship (nolock)
	where rC_Bios__Contact_1__c is not null or rC_Bios__Contact_2__c is not null

	insert into ODW.dbo.DimAccountRelationship([Received Connection ID], [Sent Connection ID], [Created By ID], [Created Date], [Record ID], Deleted, [Last Activity Date], [Last Modified By ID], 
	[Last Modified Date], [Reference #], [Owner ID], [Account From], [Account To], [Active?], [Archive?], Category, Comments, [Comments?], [Contact From], [Contact To], Degree, Department, 
	[Graduation Year], [Job Title], Major, Opportunity, Position, [Primary?], [Role @Deprecated(Version=2.0)], [Role 1], [Role 2], [Starting Day], [Starting Month], [Starting Year], 
	[Stopping Day], [Stopping Month], [Stopping Year], [Record Type ID], [System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,rC_Bios__Account_1__c,rC_Bios__Account_2__c,rC_Bios__Active__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Category__c,rC_Bios__Comments__c,rC_Bios__Comments_Flag__c,rC_Bios__Contact_1__c,rC_Bios__Contact_2__c,rC_Bios__Degree__c,rC_Bios__Department__c,rC_Bios__Graduation_Year__c,
	rC_Bios__Job_Title__c,rC_Bios__Major__c,rC_Bios__Opportunity__c,rC_Bios__Position__c,rC_Bios__Primary__c,rC_Bios__Role__c,rC_Bios__Role_1__c,rC_Bios__Role_2__c,rC_Bios__Starting_Day__c,rC_Bios__Starting_Month__c,
	rC_Bios__Starting_Year__c,rC_Bios__Stopping_Day__c,rC_Bios__Stopping_Month__c,rC_Bios__Stopping_Year__c,RecordTypeId,SystemModstamp
	from ODW_Stage.dbo.Relationship (nolock)
	where rC_Bios__Account_1__c is not null or rC_Bios__Account_2__c is not null
*/

	-- Account
	insert into ODW.dbo.DimAccount([Account Name no Household],[Account Number],[Annual Revenue],[Account#],[Billing City],[Billing Country],[Billing Zip/Postal Code],[Billing State/Province],
	[Billing Street],[Capacity Rating],[Capacity Rating Last Reviewed],[Charter School],[City Year Location ID],[City Year Moment],[City Year Service Location],[Received Connection ID],
	[Sent Connection ID],[Created By ID],[Created Date],[Current Partner],[Current Partner District],[Current School Partnerships],[CY Board],[Account Description],[Donor Retention],[Equal Distribution of Feeders],
	[Account Fax],[Highest Grade],[Account ID],[In Scale Plan],[Inclination Rating],[Inclination Rating Last Reviewed],[Industry],[Information System Notes],[Is Parent Account?],[Customer Portal Account],
	[Deleted],[Last Activity],[Last Modified By ID],[Last Modified Date],[Link to Account],[Lowest Grade],[Low Grade (Formula_not_displayed)],[Magnet School],[Major Donor Status],[Master Record ID],
	[Account Name],[National Leadership Sponsor?],[Number of Accounts],[Number of Feeder Schools],[Number of Grades],[Employees],[Owner ID],[Ownership],[Parent Account ID],[Partnership Level],
	[Account Phone],[Preferred Contact First Name],[Raiser's Edge ID],[Account Rating],[About Us],[Acquired Date],[Acquired Source],[Active],[Agency],[Archive?],[Category],[@Deprecated(Version=2.10)],
	[Funding Area],[Preferred Billing Address],[Preferred Contact],[Preferred Contact Demographic Profile],[Preferred Contact Email],[Preferred Contact Phone],[Preferred Shipping Address],[Recover?],
	[Rollup Addresses],[Salutation],[Warning Comments],[Current Calendar Year Hard Credit Amount],[Current Calendar Year Hard Credit Count],[Current Year Hard Credit Amount],[Current Year Hard Credit Count],
	[Current Year Major Giver?],[Current Year Sustaining Giver?],[Current Year Soft Credit Amount],[Current Year Soft Credit Count],[Deduct Items?],[Distribution Frequency],[First Hard Credit Amount],
	[First Hard Credit Date],[First Soft Credit Amount],[First Soft Credit Date],[Installments Allowed?],[Sustaining Giver?],[Items Allowed?],[Largest Hard Credit Amount],[Largest Hard Credit Date],
	[Largest Soft Credit Amount],[Largest Soft Credit Date],[Last Hard Credit Amount],[Last Hard Credit Date],[Last Soft Credit Amount],[Last Soft Credit Date],[Lifetime Hard Credit Amount],
	[Lifetime Hard Credit Count],[Lifetime Major Giver?],[Lifetime Sustaining Giver?],[Lifetime Soft Credit Amount],[Lifetime Soft Credit Count],[Match Ratio],[Maximum Contribution],
	[Maximum Matched],[Minimum Matched],[Pending Payment?],[Pending Payment Details],[Primary Affiliation],[Primary Giving Level],[Primary Membership Expiration Date],[Primary Membership Status],
	[Prior Calendar Year Hard Credit Amount],[Prior Calendar Year Hard Credit Count],[Prior Year Hard Credit Amount],[Prior Year Hard Credit Count],[Prior Year Major Giver?],
	[Prior Year Sustaining Giver?],[Prior Year Soft Credit Amount],[Prior Year Soft Credit Count],[Recalculate Giving?],[Rollup Affiliations],[Rollup Affiliations Status],
	[Rollup Hard Credits],[Rollup Hard Credits Status],[Rollup Soft Credits],[Rollup Soft Credits Status],[Rollup Summaries],[Rollup Summaries Status],[Track Affiliations?],
	[Track Hard Credits?],[Track Soft Credits?],[Track Summaries?],[Update Gift Membership Summaries],[Update Lifetime Summaries],[Update Summaries],[Record Merge Notes],[Record Type ID],
	[Shipping City],[Shipping Country],[Shipping Zip/Postal Code],[Shipping State/Province],[Shipping Street],[SIC Code],[Account Site],[Sort Key],[Subtype],[Sum of Gifts],[System Modstamp],
	[Tax Receipt Recipient],[Ticker Symbol],[Total Past Partnerships],[Account Type],[Wealth Rating],[Wealth Rating Last Reviewed],[Website], [Customer Category WD Code],
	[Account#-Account Name], [City Year Alumni Household], [WE Estimated Annual Donation], [WE P2G Score], [We Gift Capacity Range])
	select Account_Name_no_Household__c,AccountNumber,AnnualRevenue,Auto_Account__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Capacity_Rating__c,
	Capacity_Rating_Last_Reviewed__c,Charter_School__c,City_Year_Location_ID__c,City_Year_Moment__c,City_Year_Service_Location__c,ConnectionReceivedId,ConnectionSentId,CreatedById,
	CreatedDate,Current_Partner__c,Current_Partner_District__c,Current_School_Partnerships__c,CY_Board__c,[Description],Donor_Retention__c,Equal_Distribution_of_Feeders__c,Fax,High_Grade__c,
	Id,In_Scale_Plan__c,Inclination_Rating__c,Inclination_Rating_Last_Reviewed__c,Industry,Information_System_Notes__c,Is_Parent_Account__c,IsCustomerPortal,IsDeleted,LastActivityDate,
	LastModifiedById,LastModifiedDate,Link_to_Account__c,Low_Grade__c,Low_Grade_Formula_not_displayed__c,Magnet_School__c,Major_Donor_Status__c,MasterRecordId,Name,National_Leadership_Sponsor__c,
	Number_of_Accounts__c,Number_of_Feeder_Schools__c,Number_of_Grades__c,NumberOfEmployees,OwnerId,[Ownership],ParentId,Partnership_Level__c,Phone,Preferred_Contact_First_Name__c,Raiser_s_Edge_ID__c,
	Rating,rC_Bios__About_Us__c,rC_Bios__Acquired_Date__c,rC_Bios__Acquired_Source__c,rC_Bios__Active__c,rC_Bios__Agency__c,rC_Bios__Archive_Flag__c,rC_Bios__Category__c,rC_Bios__External_ID__c,
	rC_Bios__Funding_Area__c,rC_Bios__Preferred_Billing_Address__c,rC_Bios__Preferred_Contact__c,rC_Bios__Preferred_Contact_Demographic_Profile__c,rC_Bios__Preferred_Contact_Email__c,rC_Bios__Preferred_Contact_Phone__c,
	rC_Bios__Preferred_Shipping_Address__c,rC_Bios__Recover_Flag__c,rC_Bios__Rollup_Addresses__c,rC_Bios__Salutation__c,rC_Bios__Warning_Comments__c,rC_Giving__Current_Calendar_Year_Hard_Credit_Amount__c,
	rC_Giving__Current_Calendar_Year_Hard_Credit_Count__c,rC_Giving__Current_Year_Hard_Credit_Amount__c,rC_Giving__Current_Year_Hard_Credit_Count__c,rC_Giving__Current_Year_Is_Major_Giver__c,
	rC_Giving__Current_Year_Is_Sustaining_Giver__c,rC_Giving__Current_Year_Soft_Credit_Amount__c,rC_Giving__Current_Year_Soft_Credit_Count__c,rC_Giving__Deduct_Items__c,
	rC_Giving__Distribution_Frequency__c,rC_Giving__First_Hard_Credit_Amount__c,rC_Giving__First_Hard_Credit_Date__c,rC_Giving__First_Soft_Credit_Amount__c,rC_Giving__First_Soft_Credit_Date__c,
	rC_Giving__Installments_Allowed__c,rC_Giving__Is_Sustaining_Giver__c,rC_Giving__Items_Allowed__c,rC_Giving__Largest_Hard_Credit_Amount__c,rC_Giving__Largest_Hard_Credit_Date__c,rC_Giving__Largest_Soft_Credit_Amount__c,
	rC_Giving__Largest_Soft_Credit_Date__c,rC_Giving__Last_Hard_Credit_Amount__c,rC_Giving__Last_Hard_Credit_Date__c,rC_Giving__Last_Soft_Credit_Amount__c,rC_Giving__Last_Soft_Credit_Date__c,
	rC_Giving__Lifetime_Hard_Credit_Amount__c,rC_Giving__Lifetime_Hard_Credit_Count__c,rC_Giving__Lifetime_Is_Major_Giver__c,rC_Giving__Lifetime_Is_Sustaining_Giver__c,rC_Giving__Lifetime_Soft_Credit_Amount__c,
	rC_Giving__Lifetime_Soft_Credit_Count__c,rC_Giving__Match_Ratio__c,rC_Giving__Maximum_Contribution__c,rC_Giving__Maximum_Matched__c,rC_Giving__Minimum_Matched__c,rC_Giving__Pending_Payment__c,
	rC_Giving__Pending_Payment_Details__c,rC_Giving__Primary_Affiliation__c,rC_Giving__Primary_Giving_Level__c,rC_Giving__Primary_Membership_Expiration_Date__c,rC_Giving__Primary_Membership_Status__c,
	rC_Giving__Prior_Calendar_Year_Hard_Credit_Amount__c,rC_Giving__Prior_Calendar_Year_Hard_Credit_Count__c,rC_Giving__Prior_Year_Hard_Credit_Amount__c,rC_Giving__Prior_Year_Hard_Credit_Count__c,
	rC_Giving__Prior_Year_Is_Major_Giver__c,rC_Giving__Prior_Year_Is_Sustaining_Giver__c,rC_Giving__Prior_Year_Soft_Credit_Amount__c,rC_Giving__Prior_Year_Soft_Credit_Count__c,rC_Giving__Recalculate_Giving__c,
	rC_Giving__Rollup_Affiliations__c,rC_Giving__Rollup_Affiliations_Status__c,rC_Giving__Rollup_Hard_Credits__c,rC_Giving__Rollup_Hard_Credits_Status__c,rC_Giving__Rollup_Soft_Credits__c,
	rC_Giving__Rollup_Soft_Credits_Status__c,rC_Giving__Rollup_Summaries__c,rC_Giving__Rollup_Summaries_Status__c,rC_Giving__Track_Affiliations__c,rC_Giving__Track_Hard_Credits__c,rC_Giving__Track_Soft_Credits__c,
	rC_Giving__Track_Summaries__c,rC_Giving__Update_Gift_Membership_Summaries__c,rC_Giving__Update_Lifetime_Summaries__c,rC_Giving__Update_Summaries__c,Record_Merge_Notes__c,RecordTypeId,
	ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,Sic,[Site],Sort_Key__c,Subtype__c,Sum_of_Gifts__c,SystemModstamp,Tax_Receipt_Recipient__c,TickerSymbol,
	Total_Past_Partnerships__c,[Type],Wealth_Rating__c,Wealth_Rating_Last_Reviewed__c,Website, [Customer_Category_WD_Code__c], [Account_Account_Name__c], [City_Year_Alumni_Household__c], [WE_Estimated_Annual_Donation__c], [WE_P2G_Score__c], [WE_Gift_Capacity_Range__c]
	from ODW_Stage.dbo.Account (nolock)


	-- Credit Account
	insert into ODW.dbo.DimCreditAccount([Account Name no Household],[Account Number],[Annual Revenue],[Account#],[Billing City],[Billing Country],[Billing Zip/Postal Code],[Billing State/Province],
	[Billing Street],[Capacity Rating],[Capacity Rating Last Reviewed],[Charter School],[City Year Location ID],[City Year Moment],[City Year Service Location],[Received Connection ID],
	[Sent Connection ID],[Created By ID],[Created Date],[Current Partner],[Current Partner District],[Current School Partnerships],[CY Board],[Account Description],[Donor Retention],[Equal Distribution of Feeders],
	[Account Fax],[Highest Grade],[Account ID],[In Scale Plan],[Inclination Rating],[Inclination Rating Last Reviewed],[Industry],[Information System Notes],[Is Parent Account?],[Customer Portal Account],
	[Deleted],[Last Activity],[Last Modified By ID],[Last Modified Date],[Link to Account],[Lowest Grade],[Low Grade (Formula_not_displayed)],[Magnet School],[Major Donor Status],[Master Record ID],
	[Account Name],[National Leadership Sponsor?],[Number of Accounts],[Number of Feeder Schools],[Number of Grades],[Employees],[Owner ID],[Ownership],[Parent Account ID],[Partnership Level],
	[Account Phone],[Preferred Contact First Name],[Raiser's Edge ID],[Account Rating],[About Us],[Acquired Date],[Acquired Source],[Active],[Agency],[Archive?],[Category],[@Deprecated(Version=2.10)],
	[Funding Area],[Preferred Billing Address],[Preferred Contact],[Preferred Contact Demographic Profile],[Preferred Contact Email],[Preferred Contact Phone],[Preferred Shipping Address],[Recover?],
	[Rollup Addresses],[Salutation],[Warning Comments],[Current Calendar Year Hard Credit Amount],[Current Calendar Year Hard Credit Count],[Current Year Hard Credit Amount],[Current Year Hard Credit Count],
	[Current Year Major Giver?],[Current Year Sustaining Giver?],[Current Year Soft Credit Amount],[Current Year Soft Credit Count],[Deduct Items?],[Distribution Frequency],[First Hard Credit Amount],
	[First Hard Credit Date],[First Soft Credit Amount],[First Soft Credit Date],[Installments Allowed?],[Sustaining Giver?],[Items Allowed?],[Largest Hard Credit Amount],[Largest Hard Credit Date],
	[Largest Soft Credit Amount],[Largest Soft Credit Date],[Last Hard Credit Amount],[Last Hard Credit Date],[Last Soft Credit Amount],[Last Soft Credit Date],[Lifetime Hard Credit Amount],
	[Lifetime Hard Credit Count],[Lifetime Major Giver?],[Lifetime Sustaining Giver?],[Lifetime Soft Credit Amount],[Lifetime Soft Credit Count],[Match Ratio],[Maximum Contribution],
	[Maximum Matched],[Minimum Matched],[Pending Payment?],[Pending Payment Details],[Primary Affiliation],[Primary Giving Level],[Primary Membership Expiration Date],[Primary Membership Status],
	[Prior Calendar Year Hard Credit Amount],[Prior Calendar Year Hard Credit Count],[Prior Year Hard Credit Amount],[Prior Year Hard Credit Count],[Prior Year Major Giver?],
	[Prior Year Sustaining Giver?],[Prior Year Soft Credit Amount],[Prior Year Soft Credit Count],[Recalculate Giving?],[Rollup Affiliations],[Rollup Affiliations Status],
	[Rollup Hard Credits],[Rollup Hard Credits Status],[Rollup Soft Credits],[Rollup Soft Credits Status],[Rollup Summaries],[Rollup Summaries Status],[Track Affiliations?],
	[Track Hard Credits?],[Track Soft Credits?],[Track Summaries?],[Update Gift Membership Summaries],[Update Lifetime Summaries],[Update Summaries],[Record Merge Notes],[Record Type ID],
	[Shipping City],[Shipping Country],[Shipping Zip/Postal Code],[Shipping State/Province],[Shipping Street],[SIC Code],[Account Site],[Sort Key],[Subtype],[Sum of Gifts],[System Modstamp],
	[Tax Receipt Recipient],[Ticker Symbol],[Total Past Partnerships],[Account Type],[Wealth Rating],[Wealth Rating Last Reviewed],[Website])
	select Account_Name_no_Household__c,AccountNumber,AnnualRevenue,Auto_Account__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,Capacity_Rating__c,
	Capacity_Rating_Last_Reviewed__c,Charter_School__c,City_Year_Location_ID__c,City_Year_Moment__c,City_Year_Service_Location__c,ConnectionReceivedId,ConnectionSentId,CreatedById,
	CreatedDate,Current_Partner__c,Current_Partner_District__c,Current_School_Partnerships__c,CY_Board__c,[Description],Donor_Retention__c,Equal_Distribution_of_Feeders__c,Fax,High_Grade__c,
	Id,In_Scale_Plan__c,Inclination_Rating__c,Inclination_Rating_Last_Reviewed__c,Industry,Information_System_Notes__c,Is_Parent_Account__c,IsCustomerPortal,IsDeleted,LastActivityDate,
	LastModifiedById,LastModifiedDate,Link_to_Account__c,Low_Grade__c,Low_Grade_Formula_not_displayed__c,Magnet_School__c,Major_Donor_Status__c,MasterRecordId,Name,National_Leadership_Sponsor__c,
	Number_of_Accounts__c,Number_of_Feeder_Schools__c,Number_of_Grades__c,NumberOfEmployees,OwnerId,[Ownership],ParentId,Partnership_Level__c,Phone,Preferred_Contact_First_Name__c,Raiser_s_Edge_ID__c,
	Rating,rC_Bios__About_Us__c,rC_Bios__Acquired_Date__c,rC_Bios__Acquired_Source__c,rC_Bios__Active__c,rC_Bios__Agency__c,rC_Bios__Archive_Flag__c,rC_Bios__Category__c,rC_Bios__External_ID__c,
	rC_Bios__Funding_Area__c,rC_Bios__Preferred_Billing_Address__c,rC_Bios__Preferred_Contact__c,rC_Bios__Preferred_Contact_Demographic_Profile__c,rC_Bios__Preferred_Contact_Email__c,rC_Bios__Preferred_Contact_Phone__c,
	rC_Bios__Preferred_Shipping_Address__c,rC_Bios__Recover_Flag__c,rC_Bios__Rollup_Addresses__c,rC_Bios__Salutation__c,rC_Bios__Warning_Comments__c,rC_Giving__Current_Calendar_Year_Hard_Credit_Amount__c,
	rC_Giving__Current_Calendar_Year_Hard_Credit_Count__c,rC_Giving__Current_Year_Hard_Credit_Amount__c,rC_Giving__Current_Year_Hard_Credit_Count__c,rC_Giving__Current_Year_Is_Major_Giver__c,
	rC_Giving__Current_Year_Is_Sustaining_Giver__c,rC_Giving__Current_Year_Soft_Credit_Amount__c,rC_Giving__Current_Year_Soft_Credit_Count__c,rC_Giving__Deduct_Items__c,
	rC_Giving__Distribution_Frequency__c,rC_Giving__First_Hard_Credit_Amount__c,rC_Giving__First_Hard_Credit_Date__c,rC_Giving__First_Soft_Credit_Amount__c,rC_Giving__First_Soft_Credit_Date__c,
	rC_Giving__Installments_Allowed__c,rC_Giving__Is_Sustaining_Giver__c,rC_Giving__Items_Allowed__c,rC_Giving__Largest_Hard_Credit_Amount__c,rC_Giving__Largest_Hard_Credit_Date__c,rC_Giving__Largest_Soft_Credit_Amount__c,
	rC_Giving__Largest_Soft_Credit_Date__c,rC_Giving__Last_Hard_Credit_Amount__c,rC_Giving__Last_Hard_Credit_Date__c,rC_Giving__Last_Soft_Credit_Amount__c,rC_Giving__Last_Soft_Credit_Date__c,
	rC_Giving__Lifetime_Hard_Credit_Amount__c,rC_Giving__Lifetime_Hard_Credit_Count__c,rC_Giving__Lifetime_Is_Major_Giver__c,rC_Giving__Lifetime_Is_Sustaining_Giver__c,rC_Giving__Lifetime_Soft_Credit_Amount__c,
	rC_Giving__Lifetime_Soft_Credit_Count__c,rC_Giving__Match_Ratio__c,rC_Giving__Maximum_Contribution__c,rC_Giving__Maximum_Matched__c,rC_Giving__Minimum_Matched__c,rC_Giving__Pending_Payment__c,
	rC_Giving__Pending_Payment_Details__c,rC_Giving__Primary_Affiliation__c,rC_Giving__Primary_Giving_Level__c,rC_Giving__Primary_Membership_Expiration_Date__c,rC_Giving__Primary_Membership_Status__c,
	rC_Giving__Prior_Calendar_Year_Hard_Credit_Amount__c,rC_Giving__Prior_Calendar_Year_Hard_Credit_Count__c,rC_Giving__Prior_Year_Hard_Credit_Amount__c,rC_Giving__Prior_Year_Hard_Credit_Count__c,
	rC_Giving__Prior_Year_Is_Major_Giver__c,rC_Giving__Prior_Year_Is_Sustaining_Giver__c,rC_Giving__Prior_Year_Soft_Credit_Amount__c,rC_Giving__Prior_Year_Soft_Credit_Count__c,rC_Giving__Recalculate_Giving__c,
	rC_Giving__Rollup_Affiliations__c,rC_Giving__Rollup_Affiliations_Status__c,rC_Giving__Rollup_Hard_Credits__c,rC_Giving__Rollup_Hard_Credits_Status__c,rC_Giving__Rollup_Soft_Credits__c,
	rC_Giving__Rollup_Soft_Credits_Status__c,rC_Giving__Rollup_Summaries__c,rC_Giving__Rollup_Summaries_Status__c,rC_Giving__Track_Affiliations__c,rC_Giving__Track_Hard_Credits__c,rC_Giving__Track_Soft_Credits__c,
	rC_Giving__Track_Summaries__c,rC_Giving__Update_Gift_Membership_Summaries__c,rC_Giving__Update_Lifetime_Summaries__c,rC_Giving__Update_Summaries__c,Record_Merge_Notes__c,RecordTypeId,
	ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,Sic,[Site],Sort_Key__c,Subtype__c,Sum_of_Gifts__c,SystemModstamp,Tax_Receipt_Recipient__c,TickerSymbol,
	Total_Past_Partnerships__c,[Type],Wealth_Rating__c,Wealth_Rating_Last_Reviewed__c,Website
	from ODW_Stage.dbo.Account (nolock)

	-- Campaign
	insert into ODW.dbo.DimCampaign([Actual Cost],[Total Value Opportunities],[Total Value Won Opportunities],[Budgeted Cost],[Record Type ID],[Created By ID],[Created Date],[DB Campaign Tactic],
	[Description],[End Date],[Expected Response (%)],[Expected Revenue],[Fiscal Year],[Functional Area],[Functional Area Code],[Total Actual Cost in Hierarchy],[Total Value Opportunities in Hierarchy],
	[Total Value Won Opportunities in Hierarchy],[Total Budgeted Cost in Hierarchy],[Total Expected Revenue in Hierarchy],[Total Contacts in Hierarchy],[Total Converted Leads in Hierarchy],
	[Total Leads in Hierarchy],[Total Opportunities in Hierarchy],[Total Responses in Hierarchy],[Total Won Opportunities in Hierarchy],[Total Num Sent in Hierarchy],[Campaign ID],[Active],
	[Deleted],[Last Activity],[Last Modified By ID],[Last Modified Date],[Location],[Location Code],[Name],[Total Contacts],[Converted Leads],[Total Leads],[Num Total Opportunities],[Total Responses],
	[Num Won Opportunities],[Num Sent],[Owner ID],[Parent Campaign ID],[Duration],[Form Mapping],[Heartland Merchant],[Payment Processor],[Sage Merchant],[Added To Waitlist Text],[Attended],
	[Available Registered Count],[Available Waitlisted Count],[Event End Date/Time],[Event Code],[Event Sub-Type],[Event Type],[Hide Attendance?],[Hide Attributes?],[Hide Chatter?],[Hide Details?],
	[Hide Form?],[Hide Groups?],[Hide Meals?],[Hide Members?],[Hide Seating?],[Hide Sessions?],[Hide Tasks?],[Hide Tickets?],[Hide Venues?],[No Show],[Parent Campaign Name],[Pricebook ID],[Pricebook Link],
	[Pricebook Name],[Primary Venue],[Registered Count],[Registered Full Date],[Registered Full Text],[Registered Limit],[Registered Status],[Registration Closed Message],[Registration Edit Deadline],
	[Registration End Date/Time],[Registration Landing Page],[Registration Start Date/Time],[Rollup Members],[Rollup Venues],[Session Status],[Special Instructions],[Event Start Date/Time],[Time Zone],
	[Venue Count],[Waitlisted Count],[Waitlisted Full Date],[Waitlisted Full Text],[Waitlisted Limit],[Waitlisted Status],[Affiliation],[Appeal Segment],[Archive?],[Average Gift],[Average Gift - Hierarchy],
	[Best Case Amount],[Best Case Amount - Hierarchy],[Best Case Bar],[Best Case Ratio],[Campaign Category],[Campaign Type],[Channel],[Closed Amount],[Closed Amount - Hierarchy],[Closed Bar],[Closed Ratio],
	[Commit Amount],[Commit Amount - Hierarchy],[Commit Bar],[Commit Ratio],[Cost Per Piece],[Cost Per Piece - Hierarchy],[Cost Per Thousand],[Cost Per Thousand - Hierarchy],[Creative Package],
	[Current Giving Amount],[Current Giving Amount - Hierarchy],[Effort],[End Date/Time],[Expected Giving Amount],[Expected Giving Amount - Hierarchy],[External ID],[General Accounting Unit],[Giving Type],
	[Giving Type Engine],[Parent Campaign],[Shopper?],[Omitted Amount],[Omitted Amount - Hierarchy],[Omitted Bar],[Omitted Ratio],[Percent Goal],[Percent Goal - Hierarchy],[Pipeline Amount],
	[Pipeline Amount - Hierarchy],[Pipeline Bar],[Pipeline Ratio],[Refunded Amount],[Refunded Amount - Hierarchy],[Refunded Bar],[Refunded Ratio],[Remaining Goal],[Remaining Goal - Hierarchy],
	[Response Mechanism],[Actual Response (%)],[Actual Response (%) - Hierarchy],[ROI (%)],[ROI (%) - Hierarchy],[Rollup Giving],[Segment],[Send To Email Campaign],[Solicitation Type],[Source Code],
	[Partial Source Code],[Start Date/Time],[Sub-Affiliation],[Sub-Channel],[Support Designation],[Record Type ID2],[Short Name],[Start Date],[Status],[Sync to Marketo?],[System Modstamp],
	[Type],[Type Code],[First Response Date],[Generate Ask Amounts?],[Last Response Date],[Unsolicited Gifts #],[Cost Per Gift],[Cost Per Won Opportunity],[Days Since Drop],[Drop Date],[Net Revenue],
	[Net Revenue - Hierarchy],[Solicitation List],[Source Code 13 Digits],[Revenue Category])
	select ActualCost,AmountAllOpportunities,AmountWonOpportunities,BudgetedCost,CampaignMemberRecordTypeId,CreatedById,CreatedDate,DB_Campaign_Tactic__c,Description,EndDate,ExpectedResponse,ExpectedRevenue,
	Fiscal_Year__c,Functional_Area__c,Functional_Area_Code__c,HierarchyActualCost,HierarchyAmountAllOpportunities,HierarchyAmountWonOpportunities,HierarchyBudgetedCost,HierarchyExpectedRevenue,
	HierarchyNumberOfContacts,HierarchyNumberOfConvertedLeads,HierarchyNumberOfLeads,HierarchyNumberOfOpportunities,HierarchyNumberOfResponses,HierarchyNumberOfWonOpportunities,HierarchyNumberSent,
	Id,IsActive,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Location__c,Location_Code__c,Name,NumberOfContacts,NumberOfConvertedLeads,NumberOfLeads,NumberOfOpportunities,NumberOfResponses,
	NumberOfWonOpportunities,NumberSent,OwnerId,ParentId,rC_Connect__Duration__c,rC_Connect__Form_Mapping__c,rC_Connect__Heartland_Merchant__c,rC_Connect__Payment_Processor__c,rC_Connect__Sage_Merchant__c,
	rC_Event__Added_To_Waitlist_Text__c,rC_Event__Attended__c,rC_Event__Available_Registered_Count__c,rC_Event__Available_Waitlisted_Count__c,rC_Event__End_Date_Time__c,rC_Event__Event_Code__c,
	rC_Event__Event_Subtype__c,rC_Event__Event_Type__c,rC_Event__Hidden_Tab_Attendance__c,rC_Event__Hidden_Tab_Attributes__c,rC_Event__Hidden_Tab_Chatter__c,rC_Event__Hidden_Tab_Details__c,
	rC_Event__Hidden_Tab_Form__c,rC_Event__Hidden_Tab_Groups__c,rC_Event__Hidden_Tab_Meals__c,rC_Event__Hidden_Tab_Members__c,rC_Event__Hidden_Tab_Seating__c,rC_Event__Hidden_Tab_Sessions__c,
	rC_Event__Hidden_Tab_Tasks__c,rC_Event__Hidden_Tab_Tickets__c,rC_Event__Hidden_Tab_Venues__c,rC_Event__No_Show__c,rC_Event__Parent_Name__c,rC_Event__Pricebook__c,rC_Event__Pricebook_Link__c,
	rC_Event__Pricebook_Name__c,rC_Event__Primary_Venue__c,rC_Event__Registered_Count__c,rC_Event__Registered_Full_Date__c,rC_Event__Registered_Full_Text__c,rC_Event__Registered_Limit__c,
	rC_Event__Registered_Status__c,rC_Event__Registration_Closed_Message__c,rC_Event__Registration_Edit_Deadline__c,rC_Event__Registration_End_Date_Time__c,rC_Event__Registration_Landing_Page__c,
	rC_Event__Registration_Start_Date_Time__c,rC_Event__Rollup_Members__c,rC_Event__Rollup_Venues__c,rC_Event__Session_Status__c,rC_Event__Special_Instructions__c,rC_Event__Start_Date_Time__c,
	rC_Event__Time_Zone__c,rC_Event__Venue_Count__c,rC_Event__Waitlisted_Count__c,rC_Event__Waitlisted_Full_Date__c,rC_Event__Waitlisted_Full_Text__c,rC_Event__Waitlisted_Limit__c,
	rC_Event__Waitlisted_Status__c,rC_Giving__Affiliation__c,rC_Giving__Appeal_Segment__c,rC_Giving__Archive_Flag__c,rC_Giving__Average_Gift__c,rC_Giving__Average_Gift_Hierarchy__c,
	rC_Giving__Best_Case_Amount__c,rC_Giving__Best_Case_Amount_Hierarchy__c,rC_Giving__Best_Case_Bar__c,rC_Giving__Best_Case_Ratio__c,rC_Giving__Campaign_Category__c,rC_Giving__Campaign_Type__c,
	rC_Giving__Channel__c,rC_Giving__Closed_Amount__c,rC_Giving__Closed_Amount_Hierarchy__c,rC_Giving__Closed_Bar__c,rC_Giving__Closed_Ratio__c,rC_Giving__Commit_Amount__c,
	rC_Giving__Commit_Amount_Hierarchy__c,rC_Giving__Commit_Bar__c,rC_Giving__Commit_Ratio__c,rC_Giving__Cost_Per_Piece__c,rC_Giving__Cost_Per_Piece_Hierarchy__c,rC_Giving__Cost_Per_Thousand__c,
	rC_Giving__Cost_Per_Thousand_Hierarchy__c,rC_Giving__Creative_Package__c,rC_Giving__Current_Giving_Amount__c,rC_Giving__Current_Giving_Amount_Hierarchy__c,rC_Giving__Effort__c,
	rC_Giving__End_Date_Time__c,rC_Giving__Expected_Giving_Amount__c,rC_Giving__Expected_Giving_Amount_Hierarchy__c,rC_Giving__External_ID__c,rC_Giving__GAU__c,rC_Giving__Giving_Type__c,
	rC_Giving__Giving_Type_Engine__c,rC_Giving__Is_Parent__c,rC_Giving__Is_Shopper__c,rC_Giving__Omitted_Amount__c,rC_Giving__Omitted_Amount_Hierarchy__c,rC_Giving__Omitted_Bar__c,
	rC_Giving__Omitted_Ratio__c,rC_Giving__Percent_Goal__c,rC_Giving__Percent_Goal_Hierarchy__c,rC_Giving__Pipeline_Amount__c,rC_Giving__Pipeline_Amount_Hierarchy__c,rC_Giving__Pipeline_Bar__c,
	rC_Giving__Pipeline_Ratio__c,rC_Giving__Refunded_Amount__c,rC_Giving__Refunded_Amount_Hierarchy__c,rC_Giving__Refunded_Bar__c,rC_Giving__Refunded_Ratio__c,rC_Giving__Remaining_Goal__c,
	rC_Giving__Remaining_Goal_Hierarchy__c,rC_Giving__Response_Mechanism__c,rC_Giving__Response_Rate__c,rC_Giving__Response_Rate_Hierarchy__c,rC_Giving__ROI__c,rC_Giving__ROI_Hierarchy__c,
	rC_Giving__Rollup_Giving__c,rC_Giving__Segment__c,rC_Giving__Send_To_Email_Campaign__c,rC_Giving__Solicitation_Type__c,rC_Giving__Source_Code__c,rC_Giving__Source_Code_Partial__c,
	rC_Giving__Start_Date_Time__c,rC_Giving__Sub_Affiliation__c,rC_Giving__Sub_Channel__c,rC_Giving__Support_Designation__c,RecordTypeId,Short_Name__c,StartDate,Status,
	Sync_to_Marketo__c,SystemModstamp,Type,Type_Code__c,rC_Connect__First_Response_Date__c,rC_Connect__Generate_Ask_Amounts__c,rC_Connect__Last_Response_Date__c,rC_Connect__Unsolicited_Gifts__c,
	rC_Giving__Cost_Per_Gift__c,rC_Giving__Cost_Per_Won_Opportunity__c,rC_Giving__Days_Since_Drop__c,rC_Giving__Drop_Date__c,rC_Giving__Net_Revenue__c,rC_Giving__Net_Revenue_Hierarchy__c,
	rC_Giving__Solicitation_List__c,rC_Giving__Source_Code_13_Digits__c, Revenue_Category__c
	from ODW_Stage.dbo.Campaign (nolock)


	-- Campaign Member
	insert into ODW.dbo.DimCampaignMember([Attended],[Campaign ID],[Contact ID],[Created By ID],[Created Date],[First Responded Date],[Guest Of],[# Guests],[Responded],[Campaign Member ID],[Invited by],
	[Deleted],[Last Modified By ID],[Last Modified Date],[Lead ID],[Has Volunteered?],[# Hours Voluntereed],[Attendance Date],[Attendance Status],[Billing City],[Billing Country],[Billing Postal Code],
	[Billing State/Province],[Billing Street],[Billing Street Line 1],[Billing Street Line 2],[Campaign Group 1],[Campaign Group 2],[Campaign Group 3],[Card Expiration Month],[Card Expiration Year],
	[Card Holder Name],[Card Number],[Card Security Code],[Contact Address Type],[Email],[First Name],[Guest Of2],[Selected?],[Item 1: Item ID],[Item 1: Purchase Price],[Item 1: Purchase Quantity],
	[Item 2: Item ID],[Item 2: Purchase Price],[Item 2: Purchase Quantity],[Item 3: Item ID],[Item 3: Purchase Price],[Item 3: Purchase Quantity],[Item 4: Item ID],[Item 4: Purchase Price],
	[Item 4: Purchase Quantity],[Item 5: Item ID],[Item 5: Purchase Price],[Item 5: Purchase Quantity],[Item ID Quantity Zero],[Last Name],[Meal 1: Meal ID],[Meal 1: Purchase Price],
	[Meal 1: Purchase Quantity],[Meal 1: Status],[Meal 2: Meal ID],[Meal 2: Purchase Price],[Meal 2: Purchase Quantity],[Meal 2: Status],[Meal 3: Meal ID],[Meal 3: Purchase Price],
	[Meal 3: Purchase Quantity],[Meal 3: Status],[Meal 4: Meal ID],[Meal 4: Purchase Price],[Meal 4: Purchase Quantity],[Meal 4: Status],[Meal 5: Meal ID],[Meal 5: Purchase Price],
	[Meal 5: Purchase Quantity],[Meal 5: Status],[Meal ID Quantity Zero],[Member Email],[Member Name],[Member Phone],[Member Role],[Parent Campaign Member],[Payment Method],[Payment Processor],
	[Payment Processor Foreign GUID],[Payment Processor GUID],[Payment Status],[Payment Transaction Time],[Phone],[Registered Count],[Registered Date],[Registered Meal],[Registered Seat #],
	[Registered Status],[Registered Table],[Registered Table Name],[Registered Venue],[Registered Venue2],[Registered Venue Seats],[Salutation],[Shipping City],[Shipping Country],[Shipping Postal Code],
	[Shipping State/Province],[Shipping Street],[Shipping Street Line 1],[Shipping Street Line 2],[Ticket 1: Discount Code],[Ticket 1: Purchase Price],[Ticket 1: Purchase Quantity],[Ticket 1: Status],
	[Ticket 1: Ticket ID],[Ticket 2: Discount Code],[Ticket 2: Purchase Price],[Ticket 2: Purchase Quantity],[Ticket 2: Status],[Ticket 2: Ticket ID],[Ticket 3: Discount Code],[Ticket 3: Purchase Price],
	[Ticket 3: Purchase Quantity],[Ticket 3: Status],[Ticket 3: Ticket ID],[Ticket 4: Discount Code],[Ticket 4: Purchase Price],[Ticket 4: Purchase Quantity],[Ticket 4: Status],[Ticket 4: Ticket ID],
	[Ticket 5: Discount Code],[Ticket 5: Purchase Price],[Ticket 5: Purchase Quantity],[Ticket 5: Status],[Ticket 5: Ticket ID],[Ticket ID Quantity Zero],[Archive?],[Send To Email Campaign],
	[Record Type ID],[Representative of],[Seat Number],[Seating Description],[Status],[System Modstamp],[Table Name],[Ask 1 Amount],[Ask 2 Amount],[Ask 3 Amount],[Ask 4 Amount],[Ask 5 Amount],[Campaign Ask],[Opportunity],[Nickname],[Gave at Event?],[Event Gift Amount])
	select Attended__c,CampaignId,ContactId,CreatedById,CreatedDate,FirstRespondedDate,GuestOf__c,Guests__c,HasResponded,Id,Invited_by__c,IsDeleted,LastModifiedById,LastModifiedDate,LeadId,
	rC_Connect__Has_Volunteered__c,rC_Connect__Hours_Voluntered__c,rC_Event__Attendance_Date__c,rC_Event__Attendance_Status__c,rC_Event__Billing_City__c,rC_Event__Billing_Country__c,
	rC_Event__Billing_Postal_Code__c,rC_Event__Billing_State__c,rC_Event__Billing_Street__c,rC_Event__Billing_Street_Line_1__c,rC_Event__Billing_Street_Line_2__c,rC_Event__Campaign_Group_1__c,
	rC_Event__Campaign_Group_2__c,rC_Event__Campaign_Group_3__c,rC_Event__Card_Expiration_Month__c,rC_Event__Card_Expiration_Year__c,rC_Event__Card_Holder_Name__c,rC_Event__Card_Number__c,
	rC_Event__Card_Security_Code__c,rC_Event__Contact_Address_Type__c,rC_Event__Email__c,rC_Event__First_Name__c,rC_Event__Guest_Of__c,rC_Event__Is_Selected__c,rC_Event__Item_1_Item_ID__c,
	rC_Event__Item_1_Purchase_Price__c,rC_Event__Item_1_Purchase_Quantity__c,rC_Event__Item_2_Item_ID__c,rC_Event__Item_2_Purchase_Price__c,rC_Event__Item_2_Purchase_Quantity__c,
	rC_Event__Item_3_Item_ID__c,rC_Event__Item_3_Purchase_Price__c,rC_Event__Item_3_Purchase_Quantity__c,rC_Event__Item_4_Item_ID__c,rC_Event__Item_4_Purchase_Price__c,
	rC_Event__Item_4_Purchase_Quantity__c,rC_Event__Item_5_Item_ID__c,rC_Event__Item_5_Purchase_Price__c,rC_Event__Item_5_Purchase_Quantity__c,rC_Event__Item_ID_Quantity_Zero__c,rC_Event__Last_Name__c,
	rC_Event__Meal_1_Meal_ID__c,rC_Event__Meal_1_Purchase_Price__c,rC_Event__Meal_1_Purchase_Quantity__c,rC_Event__Meal_1_Status__c,rC_Event__Meal_2_Meal_ID__c,rC_Event__Meal_2_Purchase_Price__c,
	rC_Event__Meal_2_Purchase_Quantity__c,rC_Event__Meal_2_Status__c,rC_Event__Meal_3_Meal_ID__c,rC_Event__Meal_3_Purchase_Price__c,rC_Event__Meal_3_Purchase_Quantity__c,rC_Event__Meal_3_Status__c,
	rC_Event__Meal_4_Meal_ID__c,rC_Event__Meal_4_Purchase_Price__c,rC_Event__Meal_4_Purchase_Quantity__c,rC_Event__Meal_4_Status__c,rC_Event__Meal_5_Meal_ID__c,rC_Event__Meal_5_Purchase_Price__c,
	rC_Event__Meal_5_Purchase_Quantity__c,rC_Event__Meal_5_Status__c,rC_Event__Meal_ID_Quantity_Zero__c,rC_Event__Member_Email__c,rC_Event__Member_Name__c,rC_Event__Member_Phone__c,
	rC_Event__Member_Role__c,rC_Event__Parent_Campaign_Member__c,rC_Event__Payment_Method__c,rC_Event__Payment_Processor__c,rC_Event__Payment_Processor_Foreign_GUID__c,rC_Event__Payment_Processor_GUID__c,
	rC_Event__Payment_Status__c,rC_Event__Payment_Transaction_Time__c,rC_Event__Phone__c,rC_Event__Registered_Count__c,rC_Event__Registered_Date__c,rC_Event__Registered_Meal__c,rC_Event__Registered_Seat__c,
	rC_Event__Registered_Status__c,rC_Event__Registered_Table__c,rC_Event__Registered_Table_Name__c,rC_Event__Registered_Venue__c,rC_Event__Registered_Venue_Name__c,rC_Event__Registered_Venue_Seats__c,
	rC_Event__Salutation__c,rC_Event__Shipping_City__c,rC_Event__Shipping_Country__c,rC_Event__Shipping_Postal_Code__c,rC_Event__Shipping_State__c,rC_Event__Shipping_Street__c,
	rC_Event__Shipping_Street_Line_1__c,rC_Event__Shipping_Street_Line_2__c,rC_Event__Ticket_1_Discount_Code__c,rC_Event__Ticket_1_Purchase_Price__c,rC_Event__Ticket_1_Purchase_Quantity__c,
	rC_Event__Ticket_1_Status__c,rC_Event__Ticket_1_Ticket_ID__c,rC_Event__Ticket_2_Discount_Code__c,rC_Event__Ticket_2_Purchase_Price__c,rC_Event__Ticket_2_Purchase_Quantity__c,
	rC_Event__Ticket_2_Status__c,rC_Event__Ticket_2_Ticket_ID__c,rC_Event__Ticket_3_Discount_Code__c,rC_Event__Ticket_3_Purchase_Price__c,rC_Event__Ticket_3_Purchase_Quantity__c,
	rC_Event__Ticket_3_Status__c,rC_Event__Ticket_3_Ticket_ID__c,rC_Event__Ticket_4_Discount_Code__c,rC_Event__Ticket_4_Purchase_Price__c,rC_Event__Ticket_4_Purchase_Quantity__c,
	rC_Event__Ticket_4_Status__c,rC_Event__Ticket_4_Ticket_ID__c,rC_Event__Ticket_5_Discount_Code__c,rC_Event__Ticket_5_Purchase_Price__c,rC_Event__Ticket_5_Purchase_Quantity__c,
	rC_Event__Ticket_5_Status__c,rC_Event__Ticket_5_Ticket_ID__c,rC_Event__Ticket_ID_Quantity_Zero__c,rC_Giving__Archive_Flag__c,rC_Giving__Send_To_Email_Campaign__c,RecordTypeId,
	Representativeof__c,Seat_Number__c,Seating_Description__c,Status,SystemModstamp,Table_Name__c, [rC_Connect__Ask_1_Amount__c],[rC_Connect__Ask_2_Amount__c],[rC_Connect__Ask_3_Amount__c],[rC_Connect__Ask_4_Amount__c],[rC_Connect__Ask_5_Amount__c],[rC_Connect__Campaign_Ask__c],[rC_Connect__Opportunity__c],[Nickname__c],[Gave_at_Event__c],[Event_Gift_Amount__c]
	from ODW_Stage.dbo.CampaignMember (nolock)


	-- Contact
	insert into ODW.dbo.DimContact([Account ID],[Assistant's Name],[Asst. Phone],[Behavior Score],[Birthdate],[CampaignEvent],[Allow Customer Portal Self-Registration],[City Year Alumni],
	[City Year Worker Department],[City Year Worker Email],[City Year Worker ID],[City Year Worker Location],[City Year Worker Phone],[City Year Worker Title],[City Year Worker Type],
	[Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[CY Board Member],[Demographic Score],[Department],[Contact Description],[Do Not Call],[Email],[Email Bounced Date],
	[Email Bounced Reason],[Business Fax],[First Name],[Email Opt Out],[Fax Opt Out],[Home Phone],[Contact ID],[Deleted],[Last Activity],[Last Stay-in-Touch Request Date],[Last Stay-in-Touch Save Date],
	[Last Modified By ID],[Last Modified Date],[Last Name],[Lead Source],[Mailing City],[Mailing Country],[Mailing Zip/Postal Code],[Mailing State/Province],[Mailing Street],[Master Record ID],
	[Acquisition Date],[Acquisition Program],[Acquisition Program Id],[Inferred City],[Inferred Company],[Inferred Country],[Inferred Metropolitan Area],[Inferred Phone Area Code],[Inferred Postal Code],
	[Inferred State Region],[Lead Score],[Original Referrer],[Original Search Engine],[Original Search Phrase],[Original Source Info],[Original Source Type],[Mobile Phone],[Full Name],[Nickname],
	[Other City],[Other Country],[Other Phone],[Other Zip/Postal Code],[Other State/Province],[Other Street],[Owner ID],[Business Phone],[Active?],[Age],[Age Range],[Archive?],[Assistant Do Not Call],
	[Assistant Email],[Assistant Email Opt Out],[Birth Day],[Birth Month],[Birth Year],[Deceased?],[Deceased Date],[Deceased Day],[Deceased Month],[Deceased Year],[Demographic Profile],[Ethnicity],
	[External Contact Number],[Facebook URL],[Gender],[Google+ URL],[Home Do Not Call],[Home Email],[Home Email Opt Out],[LinkedIn URL],[Maiden Name],[Marital Status],[Middle Name],[Minor Child?],
	[Mobile Do Not Call],[Other Do Not Call],[Other Email],[Other Email Opt Out],[Preferred Contact?],[Preferred Email],[Preferred Mailing Address],[Preferred Other Address],[Preferred Phone],
	[Role],[Rollup Addresses],[Salutation],[Secondary Contact?],[Suffix],[Twitter URL],[Website URL],[Work Do Not Call],[Work Email],[Work Email Opt Out],[Work Phone],[Current Year Soft Credit Amount],
	[Current Year Soft Credit Count],[First Soft Credit Amount],[First Soft Credit Date],[Largest Soft Credit Amount],[Largest Soft Credit Date],[Last Soft Credit Amount],[Last Soft Credit Date],
	[Lifetime Soft Credit Amount],[Lifetime Soft Credit Count],[Primary Affiliation],[Primary Giving Level],[Primary Membership Expiration Date],[Primary Membership Status],[Prior Year Soft Credit Amount],
	[Prior Year Soft Credit Count],[Rollup Soft Credits],[Rollup Soft Credits Status],[Track Soft Credits?],[Record Type ID],[Recruitment Status],[Reports To ID],[Salutation2],[Sort Key],
	[Sync to Marketo?],[System Modstamp],[Title],[Warning Comments])
	select AccountId,AssistantName,AssistantPhone,Behavior_Score__c,Birthdate,CampaignEvent__c,CanAllowPortalSelfReg,City_Year_Alumni__c,City_Year_Worker_Department__c,City_Year_Worker_Email__c,
	City_Year_Worker_ID__c,City_Year_Worker_Location__c,City_Year_Worker_Phone__c,City_Year_Worker_Title__c,City_Year_Worker_Type__c,ConnectionReceivedId,ConnectionSentId,CreatedById,
	CreatedDate,CY_Board_Member__c,Demographic_Score__c,Department,Description,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,HomePhone,
	Id,IsDeleted,LastActivityDate,LastCURequestDate,LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LeadSource,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,
	MasterRecordId,mkto2__Acquisition_Date__c,mkto2__Acquisition_Program__c,mkto2__Acquisition_Program_Id__c,mkto2__Inferred_City__c,mkto2__Inferred_Company__c,mkto2__Inferred_Country__c,
	mkto2__Inferred_Metropolitan_Area__c,mkto2__Inferred_Phone_Area_Code__c,mkto2__Inferred_Postal_Code__c,mkto2__Inferred_State_Region__c,mkto2__Lead_Score__c,mkto2__Original_Referrer__c,
	mkto2__Original_Search_Engine__c,mkto2__Original_Search_Phrase__c,mkto2__Original_Source_Info__c,mkto2__Original_Source_Type__c,MobilePhone,Name,Nickname__c,OtherCity,OtherCountry,OtherPhone,
	OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,rC_Bios__Active__c,rC_Bios__Age__c,rC_Bios__Age_Range__c,rC_Bios__Archive_Flag__c,rC_Bios__Assistant_Do_Not_Call__c,rC_Bios__Assistant_Email__c,
	rC_Bios__Assistant_Email_Opt_Out__c,rC_Bios__Birth_Day__c,rC_Bios__Birth_Month__c,rC_Bios__Birth_Year__c,rC_Bios__Deceased__c,rC_Bios__Deceased_Date__c,rC_Bios__Deceased_Day__c,rC_Bios__Deceased_Month__c,
	rC_Bios__Deceased_Year__c,rC_Bios__Demographic_Profile__c,rC_Bios__Ethnicity__c,rC_Bios__External_Contact_Number__c,rC_Bios__Facebook_Url__c,rC_Bios__Gender__c,rC_Bios__Google_Plus_Url__c,
	rC_Bios__Home_Do_Not_Call__c,rC_Bios__Home_Email__c,rC_Bios__Home_Email_Opt_Out__c,rC_Bios__LinkedIn_Url__c,rC_Bios__Maiden_Name__c,rC_Bios__Marital_Status__c,rC_Bios__Middle_Name__c,rC_Bios__Minor_Child__c,
	rC_Bios__Mobile_Do_Not_Call__c,rC_Bios__Other_Do_Not_Call__c,rC_Bios__Other_Email__c,rC_Bios__Other_Email_Opt_Out__c,rC_Bios__Preferred_Contact__c,rC_Bios__Preferred_Email__c,rC_Bios__Preferred_Mailing_Address__c,
	rC_Bios__Preferred_Other_Address__c,rC_Bios__Preferred_Phone__c,rC_Bios__Role__c,rC_Bios__Rollup_Addresses__c,rC_Bios__Salutation__c,rC_Bios__Secondary_Contact__c,rC_Bios__Suffix__c,rC_Bios__Twitter_Url__c,
	rC_Bios__Website_Url__c,rC_Bios__Work_Do_Not_Call__c,rC_Bios__Work_Email__c,rC_Bios__Work_Email_Opt_Out__c,rC_Bios__Work_Phone__c,rC_Giving__Current_Year_Soft_Credit_Amount__c,rC_Giving__Current_Year_Soft_Credit_Count__c,
	rC_Giving__First_Soft_Credit_Amount__c,rC_Giving__First_Soft_Credit_Date__c,rC_Giving__Largest_Soft_Credit_Amount__c,rC_Giving__Largest_Soft_Credit_Date__c,rC_Giving__Last_Soft_Credit_Amount__c,
	rC_Giving__Last_Soft_Credit_Date__c,rC_Giving__Lifetime_Soft_Credit_Amount__c,rC_Giving__Lifetime_Soft_Credit_Count__c,rC_Giving__Primary_Affiliation__c,rC_Giving__Primary_Giving_Level__c,
	rC_Giving__Primary_Membership_Expiration_Date__c,rC_Giving__Primary_Membership_Status__c,rC_Giving__Prior_Year_Soft_Credit_Amount__c,rC_Giving__Prior_Year_Soft_Credit_Count__c,rC_Giving__Rollup_Soft_Credits__c,
	rC_Giving__Rollup_Soft_Credits_Status__c,rC_Giving__Track_Soft_Credits__c,RecordTypeId,Recruitment_Status__c,ReportsToId,Salutation,Sort_Key__c,Sync_to_Marketo__c,SystemModstamp,Title,Warning_Comments__c
	from ODW_Stage.dbo.Contact (nolock)

	-- Campaign Contact
	insert into ODW.dbo.DimCampaignContact([Account ID],[Assistant's Name],[Asst. Phone],[Behavior Score],[Birthdate],[CampaignEvent],[Allow Customer Portal Self-Registration],[City Year Alumni],
	[City Year Worker Department],[City Year Worker Email],[City Year Worker ID],[City Year Worker Location],[City Year Worker Phone],[City Year Worker Title],[City Year Worker Type],
	[Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[CY Board Member],[Demographic Score],[Department],[Contact Description],[Do Not Call],[Email],[Email Bounced Date],
	[Email Bounced Reason],[Business Fax],[First Name],[Email Opt Out],[Fax Opt Out],[Home Phone],[Contact ID],[Deleted],[Last Activity],[Last Stay-in-Touch Request Date],[Last Stay-in-Touch Save Date],
	[Last Modified By ID],[Last Modified Date],[Last Name],[Lead Source],[Mailing City],[Mailing Country],[Mailing Zip/Postal Code],[Mailing State/Province],[Mailing Street],[Master Record ID],
	[Acquisition Date],[Acquisition Program],[Acquisition Program Id],[Inferred City],[Inferred Company],[Inferred Country],[Inferred Metropolitan Area],[Inferred Phone Area Code],[Inferred Postal Code],
	[Inferred State Region],[Lead Score],[Original Referrer],[Original Search Engine],[Original Search Phrase],[Original Source Info],[Original Source Type],[Mobile Phone],[Full Name],[Nickname],
	[Other City],[Other Country],[Other Phone],[Other Zip/Postal Code],[Other State/Province],[Other Street],[Owner ID],[Business Phone],[Active?],[Age],[Age Range],[Archive?],[Assistant Do Not Call],
	[Assistant Email],[Assistant Email Opt Out],[Birth Day],[Birth Month],[Birth Year],[Deceased?],[Deceased Date],[Deceased Day],[Deceased Month],[Deceased Year],[Demographic Profile],[Ethnicity],
	[External Contact Number],[Facebook URL],[Gender],[Google+ URL],[Home Do Not Call],[Home Email],[Home Email Opt Out],[LinkedIn URL],[Maiden Name],[Marital Status],[Middle Name],[Minor Child?],
	[Mobile Do Not Call],[Other Do Not Call],[Other Email],[Other Email Opt Out],[Preferred Contact?],[Preferred Email],[Preferred Mailing Address],[Preferred Other Address],[Preferred Phone],
	[Role],[Rollup Addresses],[Salutation],[Secondary Contact?],[Suffix],[Twitter URL],[Website URL],[Work Do Not Call],[Work Email],[Work Email Opt Out],[Work Phone],[Current Year Soft Credit Amount],
	[Current Year Soft Credit Count],[First Soft Credit Amount],[First Soft Credit Date],[Largest Soft Credit Amount],[Largest Soft Credit Date],[Last Soft Credit Amount],[Last Soft Credit Date],
	[Lifetime Soft Credit Amount],[Lifetime Soft Credit Count],[Primary Affiliation],[Primary Giving Level],[Primary Membership Expiration Date],[Primary Membership Status],[Prior Year Soft Credit Amount],
	[Prior Year Soft Credit Count],[Rollup Soft Credits],[Rollup Soft Credits Status],[Track Soft Credits?],[Record Type ID],[Recruitment Status],[Reports To ID],[Salutation2],[Sort Key],
	[Sync to Marketo?],[System Modstamp],[Title],[Warning Comments])
	select [Account ID],[Assistant's Name],[Asst. Phone],[Behavior Score],[Birthdate],[CampaignEvent],[Allow Customer Portal Self-Registration],[City Year Alumni],
	[City Year Worker Department],[City Year Worker Email],[City Year Worker ID],[City Year Worker Location],[City Year Worker Phone],[City Year Worker Title],[City Year Worker Type],
	[Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[CY Board Member],[Demographic Score],[Department],[Contact Description],[Do Not Call],[Email],[Email Bounced Date],
	[Email Bounced Reason],[Business Fax],[First Name],[Email Opt Out],[Fax Opt Out],[Home Phone],[Contact ID],[Deleted],[Last Activity],[Last Stay-in-Touch Request Date],[Last Stay-in-Touch Save Date],
	[Last Modified By ID],[Last Modified Date],[Last Name],[Lead Source],[Mailing City],[Mailing Country],[Mailing Zip/Postal Code],[Mailing State/Province],[Mailing Street],[Master Record ID],
	[Acquisition Date],[Acquisition Program],[Acquisition Program Id],[Inferred City],[Inferred Company],[Inferred Country],[Inferred Metropolitan Area],[Inferred Phone Area Code],[Inferred Postal Code],
	[Inferred State Region],[Lead Score],[Original Referrer],[Original Search Engine],[Original Search Phrase],[Original Source Info],[Original Source Type],[Mobile Phone],[Full Name],[Nickname],
	[Other City],[Other Country],[Other Phone],[Other Zip/Postal Code],[Other State/Province],[Other Street],[Owner ID],[Business Phone],[Active?],[Age],[Age Range],[Archive?],[Assistant Do Not Call],
	[Assistant Email],[Assistant Email Opt Out],[Birth Day],[Birth Month],[Birth Year],[Deceased?],[Deceased Date],[Deceased Day],[Deceased Month],[Deceased Year],[Demographic Profile],[Ethnicity],
	[External Contact Number],[Facebook URL],[Gender],[Google+ URL],[Home Do Not Call],[Home Email],[Home Email Opt Out],[LinkedIn URL],[Maiden Name],[Marital Status],[Middle Name],[Minor Child?],
	[Mobile Do Not Call],[Other Do Not Call],[Other Email],[Other Email Opt Out],[Preferred Contact?],[Preferred Email],[Preferred Mailing Address],[Preferred Other Address],[Preferred Phone],
	[Role],[Rollup Addresses],[Salutation],[Secondary Contact?],[Suffix],[Twitter URL],[Website URL],[Work Do Not Call],[Work Email],[Work Email Opt Out],[Work Phone],[Current Year Soft Credit Amount],
	[Current Year Soft Credit Count],[First Soft Credit Amount],[First Soft Credit Date],[Largest Soft Credit Amount],[Largest Soft Credit Date],[Last Soft Credit Amount],[Last Soft Credit Date],
	[Lifetime Soft Credit Amount],[Lifetime Soft Credit Count],[Primary Affiliation],[Primary Giving Level],[Primary Membership Expiration Date],[Primary Membership Status],[Prior Year Soft Credit Amount],
	[Prior Year Soft Credit Count],[Rollup Soft Credits],[Rollup Soft Credits Status],[Track Soft Credits?],[Record Type ID],[Recruitment Status],[Reports To ID],[Salutation2],[Sort Key],
	[Sync to Marketo?],[System Modstamp],[Title],[Warning Comments]
	from ODW.dbo.DimContact (nolock)

	-- Account Address
	insert into ODW.dbo.DimBiosAccountAddress([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],
	[Reference #],[Account],[Active?],[Additional Line 1],[Verified Address],[Archive?],[Attention Line],[Current City],[Current Country],[Do Not Mail?],[End Date],[Current Extension],
	[Current Extension #],[External ID],[Original City],[Original Country],[Original Extension],[Original Extension #],[Original Postal Code],[Original State/Province],[Original Street Line 1],
	[Original Street Line 2],[Current Postal Code],[Preferred Billing?],[Preferred Shipping?],[Seasonal End Date],[Seasonal End Day],[Seasonal End Month],[Seasonal Start Date],[Seasonal Start Day],
	[Seasonal Start Month],[Selected?],[Start Date],[Current State/Province],[Current Street Line 1],[Current Street Line 2],[Type],[Undeliverable Count],[Verified?],[Verified Different?],
	[System Modstamp])
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,rC_Bios__Account__c,rC_Bios__Active__c,rC_Bios__Additional_Line_1__c,
	rC_Bios__Address__c,rC_Bios__Archive_Flag__c,rC_Bios__Attention_Line__c,rC_Bios__City__c,rC_Bios__Country__c,rC_Bios__Do_Not_Mail__c,rC_Bios__End_Date__c,rC_Bios__Extension__c,
	rC_Bios__Extension_Number__c,rC_Bios__External_ID__c,rC_Bios__Original_City__c,rC_Bios__Original_Country__c,rC_Bios__Original_Extension__c,rC_Bios__Original_Extension_Number__c,
	rC_Bios__Original_Postal_Code__c,rC_Bios__Original_State__c,rC_Bios__Original_Street_Line_1__c,rC_Bios__Original_Street_Line_2__c,rC_Bios__Postal_Code__c,rC_Bios__Preferred_Billing__c,
	rC_Bios__Preferred_Shipping__c,rC_Bios__Seasonal_End_Date__c,rC_Bios__Seasonal_End_Day__c,rC_Bios__Seasonal_End_Month__c,rC_Bios__Seasonal_Start_Date__c,rC_Bios__Seasonal_Start_Day__c,
	rC_Bios__Seasonal_Start_Month__c,rC_Bios__Selected__c,rC_Bios__Start_Date__c,rC_Bios__State__c,rC_Bios__Street_Line_1__c,rC_Bios__Street_Line_2__c,rC_Bios__Type__c,
	rC_Bios__Undeliverable_Count__c,rC_Bios__Verified__c,rC_Bios__Verified_Different__c,SystemModstamp 
	from ODW_Stage.dbo.rc__Bios_Account_Address__c (nolock)

	-- Contact Address
	insert into ODW.dbo.DimBiosContactAddress([Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Record ID],[Deleted],[Last Modified By ID],[Last Modified Date],
	[Reference #],[Active?],[Additional Line 1],[Verified Address],[Archive?],[Attention Line],[Current City],[Contact],[Current Country],[Do Not Mail?],[End Date],[Current Extension],
	[Current Extension #],[External ID],[Original City],[Original Country],[Original Extension],[Original Extension #],[Original Postal Code],[Original State/Province],[Original Street Line 1],
	[Original Street Line 2],[Current Postal Code],[Preferred Mailing?],[Preferred Other?],[Seasonal End Date],[Seasonal End Day],[Seasonal End Month],[Seasonal Start Date],[Seasonal Start Day],
	[Seasonal Start Month],[Selected?],[Start Date],[Current State/Province],[Current Street Line 1],[Current Street Line 2],[Type],[Undeliverable Count],[Verified?],[Verified Different?],
	[System Modstamp])	
	select ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,rC_Bios__Active__c,rC_Bios__Additional_Line_1__c,rC_Bios__Address__c,
	rC_Bios__Archive_Flag__c,rC_Bios__Attention_Line__c,rC_Bios__City__c,rC_Bios__Contact__c,rC_Bios__Country__c,rC_Bios__Do_Not_Mail__c,rC_Bios__End_Date__c,rC_Bios__Extension__c,
	rC_Bios__Extension_Number__c,rC_Bios__External_ID__c,rC_Bios__Original_City__c,rC_Bios__Original_Country__c,rC_Bios__Original_Extension__c,rC_Bios__Original_Extension_Number__c,
	rC_Bios__Original_Postal_Code__c,rC_Bios__Original_State__c,rC_Bios__Original_Street_Line_1__c,rC_Bios__Original_Street_Line_2__c,rC_Bios__Postal_Code__c,rC_Bios__Preferred_Mailing__c,
	rC_Bios__Preferred_Other__c,rC_Bios__Seasonal_End_Date__c,rC_Bios__Seasonal_End_Day__c,rC_Bios__Seasonal_End_Month__c,rC_Bios__Seasonal_Start_Date__c,rC_Bios__Seasonal_Start_Day__c,
	rC_Bios__Seasonal_Start_Month__c,rC_Bios__Selected__c,rC_Bios__Start_Date__c,rC_Bios__State__c,rC_Bios__Street_Line_1__c,rC_Bios__Street_Line_2__c,rC_Bios__Type__c,rC_Bios__Undeliverable_Count__c,
	rC_Bios__Verified__c,rC_Bios__Verified_Different__c,SystemModstamp
	from ODW_Stage.dbo.rc__Bios_Contact_Address__c (nolock) 

	-- Fact Donor
	truncate table ODW.dbo.FactDonor

	insert into ODW.dbo.FactDonor(OpportunityID, OppAccountID, OppCampaignID, AllocationID, AccountID, Hard, Soft, FY_Hard, FY_Soft)
	select a.ID OpportunityID, a.AccountId OppAccountID, a.CampaignId OppCampaignID, ODW.dbo.[DimHardCredit_Allocation].HardCreditID AllocationID, 
	ODW.dbo.DimAccount.AccountID AccountID, 
	ODW.dbo.[DimHardCredit_Allocation].[Giving Amount] as Hard,
	0 as Soft,
	ODW.dbo.[DimHardCredit_Allocation].[Fiscal Year] FY_Hard,
	ODW.dbo.[DimHardCredit_Allocation].[Fiscal Year] FY_Soft
	from ODW.dbo.[DimHardCredit_Allocation] (nolock)
	inner join (select distinct ID, AccountID, CampaignId, Fiscal_Year__c from ODW_Stage.dbo.Opportunity (nolock)) a ON
		[DimHardCredit_Allocation].Opportunity = a.Id
	inner join ODW.dbo.DimAccount (nolock) on
		a.AccountId = DimAccount.[Account Id]
	left outer join (select distinct AccountID from ODW_Stage.dbo.Contact (nolock)) c on
		DimAccount.[Account Id] = c.AccountId

	-- Fact Donor Full
	truncate table FactDonor_Full

	insert into ODW.dbo.FactDonor_Full(OpportunityID, OppAccountID, OppCampaignID, AllocationID, AccountID, Hard, Soft, FY_Hard, FY_Soft,
	[Account ID],[Amount],[Initial Application Submission Format],[Attendance Start Date],[Behavior Start Date],[Campaign: Primary Campaign],[Campaign ID],
	[CFDA#],[Closed Lost Comments],[Close Date],[Received Connection ID],[Sent Connection ID],[Application Type],[Cost Per MSY Awarded],[Cost Per MSY Requested],[Count Oppty Line Items],
	[Created By ID],[Created Date],[CY Allocation Location String],[CY Fiscal Year],[DB Competitor],[Description],[Diplomas Now School Partnership?],[Do Not Acknolwedge],[ELA Start Date],
	[Exit w/ Award],[Exit w/ No Award],[Expected Amount],[Extend Day Start Date],
	[Fiscal Period],
	--[Fiscal Year],
	[Fiscal Quarter],[Fiscal Year2],[Forecast Category],
	--[Forecast Category2],
	[Full Time],[Full-Time/Half-Time],[Gift Source],
	--[Grant Year],
	[Half Time],[Has Line Item],[i3 School Partnership?],[Opportunity ID],[Closed],[Deleted],[Private],[Won],[Key Considerations],
	[Last Activity],[Last Modified By ID],[Last Modified Date],[Lead Source],[Link to Opportunity],[Minimum Living Allowance],[Material Support],[Math Start Date],[Monitoring Success],[# MSY Awarded],
	[# MSY Requested],[Multi Indic Start Date],[Name],[Needs Receipt?],[Next Step],[# of No Cost Slots],[Number of Opportunities],[Opportunity Number],[Owner ID],[Parent Campaign: Revenue Strategy],
	[Parent Campaign: Source],[Parent Opportunity: Allocation Location],[Parent Opportunity: Do Not Acknowledge],[Parent Opportunity: Giving Source],[Parent Opportunity: Id],[Parent Opportunity: Opportunity Number],
	[Parent Opportunity: Opportunity RecType],[Parent Opportunity: Tribute Text],[Partnership End Date],[Partnership Period],[Partnership Start Date],[Partnership Year],[Preparation and Training],
	[Price Book ID],[Probability (%)],[Program Name],[Projected Amount],[Auto-Submit Payment?],[Rollup Heartland Transactions],[Rollup Sage Vault Bankcards],[Rollup Sage Vault Virtual Checks],
	[Account Name],[Account Number],[Acknowledged?],[Acknowledged Date],[Activity Type],[Affiliation],[Allocation Amount],[Anniversary Date],[Anniversary Renewal Date],[Annual Giving Amount],
	[Application Deadline],[Application ID],[Archive?],[Ask Readiness],[Available Billing Date],[Awarded Grant End Date],[Awarded Grant Start Date],[Best Case Amount],[Best Case Bar],[Best Case Ratio],
	[Calculated Giving Type],[Campaign Channel],[Campaign: Response Mechanism],[Campaign: Source Code],[Campaign: Support Designation],[Charitable Deduction],[Check Date],[Check #],[Close Date/Time],
	[Closed Amount],[Closed Bar],[Closed Lost Reason],[Closed Ratio],[Comments],[Commit Amount],[Commit Bar],[Commit Ratio],[Concept Paper Deadline],[Contract #],[Contract Status],[Current Giving Amount],
	[Current Giving Bar],[Current Giving Divergence],[Current Giving Ratio],[Discount Rate],[Discount Rate Month],[Discount Rate Year],[Effective Giving Type Date],[Enrollment Start Date],[Entered Giving Amount],
	[Entered Giving Currency],[Entered Giving Currency Rate],[Expected Giving Amount],[Expected Giving Bar],[Expected Giving Ratio],
	--[External ID],
	[Fees & Commissions],[Fill Rate],[First Closed Payment Date],
	[First Payment Date],
	--[General Accounting Unit],
	[Giving Amount],[Giving End Date],[Giving Frequency],[Giving Level ID],[Giving Level Status],[Giving #],[Giving Type],[Giving Type Engine],
	[Giving Years],[Grant Purpose],[Grant Requirements],[Grant Type],[Grantor ID],[Initial Application Submission Format2],[Internal Grant ID],[Anonymous?],[Bookable?],[Force Canceled?],[Force Completed?],
	[Giving?],[Giving Donation?],[Giving Inkind?],[Giving Membership?],[Giving Purchase?],[Giving Transaction?],[Matching?],[Payment Refunded?],[Refundable?],[Restricted?],[Selected?],[Shopper?],
	[Force Suspended?],[Sustainer?],[Tribute?],[Force Uncollectible?],[Last Giving Amount Adjustment],[Last Giving Amount Adjustment Date],[Letter of Intent Deadline],[Link # 2],[Link # 3],[Link # 4],
	[Link # 5],[Link # 6],[Matching Account],[Matching Amount],[Matching Notice],[Matching Opportunity],[Matching Status],[Media Amount 1],[Media Amount 2],[Media Amount 3],[Media Amount 4],
	[Media Amount 5],[Media Type 1],[Media Type 2],[Media Type 3],[Media Type 4],[Media Type 5],[Notice Of Grant Awarded],[Number Of Shares],[Omitted Amount],[Omitted Bar],[Omitted Ratio],
	[Original Summary],[Parent Opportunity],[Parent Opportunity: Name],[Payer Name],[Payment Count],[Payment Day],[Payment End Date],[Payment Frequency],[Payment Method],[Selected Payment Method],
	[Payment Reference #],[Performance Measures],[Pipeline Amount],[Pipeline Bar],[Pipeline Ratio],[Planned Giving],[Pre-Award Cost Approval],[Primary Contact],[Projected Amount2],[Projected Bar],
	[Projected Ratio],[Proposed End Date],[Proposed Start Date],[Prospect Rating],[Realized Amount],[Realized Date],[Refund Reason],[Refunded Amount],[Refunded Bar],[Refunded Ratio],[Renew By Email],
	[Renew By Postal Mail],[Reporting Schedule],[Requested Amount],[Response Mechanism],[Retention Rate],[Rollup Allocations],[Rollup Giving],[Rollup Transactions],[Solicitation Status],[Solicitation Type],
	[Sorting #],[Source Code],[Summary],[Summary Link],[Support Designation],[Suspended End Date],[Suspended Start Date],[Tax Deductible Amount],[Ticker Symbol],[Transaction Type],[Tribute Comments],
	[Tribute Contact],[Tribute Delivered Date],[Tribute Delivery],[Tribute Description],[Tribute Effective Date],[Tribute Name],[Tribute Type],[Update Transactions],[Valuation Date],[Valuation Type],
	[RE Date and Ext ID],[Record Type ID],[Special Gift Indicator],[Stage],[State Commission],[State Commission Contact],[System Modstamp],[Team Weekly Schedule],[Tier],[Quantity],[Opportunity Type],
	[30-Day Enrollment Compliance (# Late)],[30 Day Exit Compliance (# Late)],[Workday Integration Datetime Stamp])
	select a.ID OpportunityID, a.AccountId OppAccountID, a.CampaignId OppCampaignID, ODW.dbo.[DimHardCredit_Allocation].HardCreditID AllocationID, 
	ODW.dbo.DimAccount.AccountID AccountID, 
	case d.RecordTypeID 
		when '012U000000017QSIAY' then [DimHardCredit_Allocation].[Giving Amount]
		when '012U000000017QXIAY' then [DimHardCredit_Allocation].[Giving Amount]
		when '012U000000017QTIAY' then [DimHardCredit_Allocation].[Amount]
		else 0
	end as Hard,
	0 as Soft,
	ODW.dbo.[DimHardCredit_Allocation].[Fiscal Year] FY_Hard,
	ODW.dbo.[DimHardCredit_Allocation].[Fiscal Year] FY_Soft, 
	d.AccountId,d.Amount,Application_Submission_Format__c,Attendance_Start_Date__c,Behavior_Start_Date__c,Campaign_Primary_Campaign__c,d.CampaignId,CFDA__c,Closed_Lost_Comments__c,
	CloseDate,ConnectionReceivedId,ConnectionSentId,Continuation_Recompete__c,Cost_Per_MSY_Awarded__c,Cost_Per_MSY_Requested__c,Count_Oppty_Line_Items__c,CreatedById,CreatedDate,[DimHardCredit_Allocation].[General Accounting Unit Name] CY_Allocation_Location_String__c,
	CY_Fiscal_Year__c,DB_Competitor__c,Description,Diplomas_Now_School_Partnership__c,Do_Not_Acknolwedge__c,ELA_Start_Date__c,Exit_w_Award__c,Exit_w_No_Award__c,ExpectedRevenue,Extend_Day_Start_Date__c,
	Fiscal,
	--d.Fiscal_Year__c,
	FiscalQuarter,FiscalYear,ForecastCategory,
	--ForecastCategoryName,
	Full_Time__c,Full_time_Half_time__c,Gift_Source__c,
	--Grant_Year__c,
	Half_Time__c,HasOpportunityLineItem,i3_School_Partnership__c,
	d.Id,IsClosed,IsDeleted,IsPrivate,IsWon,Key_Considerations__c,LastActivityDate,LastModifiedById,LastModifiedDate,LeadSource,Link_to_Opportunity__c,Living_Allowance__c,Material_Support__c,Math_Start_Date__c,
	Monitoring_Success__c,MSY_Awarded__c,MSY_Requested__c,Multi_Indic_Start_Date__c,Name,Needs_Receipt__c,NextStep,No_Cost_Slots__c,Number_of_Opportunities__c,Opportunity_Number__c,OwnerId,Parent_Campaign_Revenue_Strategy__c,
	Parent_Campaign_Source__c,Parent_Opportunity_Allocation_Location__c,Parent_Opportunity_Do_Not_Acknowledge__c,Parent_Opportunity_Giving_Source__c,Parent_Opportunity_Id__c,Parent_Opportunity_Opportunity_Number__c,
	Parent_Opportunity_Opportunity_RecType__c,Parent_Opportunity_Tribute_Text__c,Partnership_End_Date__c,Partnership_Period__c,Partnership_Start_Date__c,Partnership_Year__c,Preparation_and_Training__c,
	Pricebook2Id,Probability,Program_Name__c,projected_amount__c,rC_Connect__Is_Auto_Submit_Payment__c,rC_Connect__Rollup_Heartland_Transactions__c,rC_Connect__Rollup_Sage_Vault_Bankcards__c,
	rC_Connect__Rollup_Sage_Vault_Virtual_Checks__c,rC_Giving__Account_Name__c,rC_Giving__Account_Number__c,rC_Giving__Acknowledged__c,rC_Giving__Acknowledged_Date__c,rC_Giving__Activity_Type__c,
	rC_Giving__Affiliation__c,rC_Giving__Allocation_Amount__c,rC_Giving__Anniversary_Date__c,rC_Giving__Anniversary_Renewal_Date__c,rC_Giving__Annual_Giving_Amount__c,rC_Giving__Application_Deadline__c,
	rC_Giving__Application_ID__c,rC_Giving__Archive_Flag__c,rC_Giving__Ask_Readiness__c,rC_Giving__Available_Billing_Date__c,rC_Giving__Awarded_Grant_End_Date__c,rC_Giving__Awarded_Grant_Start_Date__c,
	rC_Giving__Best_Case_Amount__c,rC_Giving__Best_Case_Bar__c,rC_Giving__Best_Case_Ratio__c,rC_Giving__Calculated_Giving_Type__c,rC_Giving__Campaign_Channel__c,rC_Giving__Campaign_Response_Mechanism__c,
	rC_Giving__Campaign_Source_Code__c,rC_Giving__Campaign_Support_Designation__c,rC_Giving__Charitable_Deduction__c,rC_Giving__Check_Date__c,rC_Giving__Check_Number__c,rC_Giving__Close_Date_Time__c,
	rC_Giving__Closed_Amount__c,rC_Giving__Closed_Bar__c,rC_Giving__Closed_Lost_Reason__c,rC_Giving__Closed_Ratio__c,rC_Giving__Comments__c,rC_Giving__Commit_Amount__c,rC_Giving__Commit_Bar__c,
	rC_Giving__Commit_Ratio__c,rC_Giving__Concept_Paper_Deadline__c,rC_Giving__Contract_Number__c,rC_Giving__Contract_Status__c,rC_Giving__Current_Giving_Amount__c,rC_Giving__Current_Giving_Bar__c,
	rC_Giving__Current_Giving_Divergence__c,rC_Giving__Current_Giving_Ratio__c,rC_Giving__Discount_Rate__c,rC_Giving__Discount_Rate_Month__c,rC_Giving__Discount_Rate_Year__c,rC_Giving__Effective_Giving_Type_Date__c,
	rC_Giving__Enrollment_Start_Date__c,rC_Giving__Entered_Giving_Amount__c,rC_Giving__Entered_Giving_Currency__c,rC_Giving__Entered_Giving_Currency_Rate__c,rC_Giving__Expected_Giving_Amount__c,
	rC_Giving__Expected_Giving_Bar__c,rC_Giving__Expected_Giving_Ratio__c,
	--rC_Giving__External_ID__c,
	rC_Giving__Fees_Commissions__c,rC_Giving__Fill_Rate__c,rC_Giving__First_Closed_Payment_Date__c,
	rC_Giving__First_Payment_Date__c,
	--rC_Giving__GAU__c,
	rC_Giving__Giving_Amount__c,rC_Giving__Giving_End_Date__c,rC_Giving__Giving_Frequency__c,rC_Giving__Giving_Level_ID__c,
	rC_Giving__Giving_Level_Status__c,rC_Giving__Giving_Number__c,rC_Giving__Giving_Type__c,rC_Giving__Giving_Type_Engine__c,rC_Giving__Giving_Years__c,rC_Giving__Grant_Purpose__c,
	rC_Giving__Grant_Requirements__c,rC_Giving__Grant_Type__c,rC_Giving__Grantor_ID__c,rC_Giving__Initial_Application_Submission_Format__c,rC_Giving__Internal_Grant_ID__c,rC_Giving__Is_Anonymous__c,
	rC_Giving__Is_Bookable__c,rC_Giving__Is_Canceled__c,rC_Giving__Is_Completed__c,rC_Giving__Is_Giving__c,rC_Giving__Is_Giving_Donation__c,rC_Giving__Is_Giving_Inkind__c,rC_Giving__Is_Giving_Membership__c,
	rC_Giving__Is_Giving_Purchase__c,rC_Giving__Is_Giving_Transaction__c,rC_Giving__Is_Matching__c,rC_Giving__Is_Payment_Refunded__c,rC_Giving__Is_Refundable__c,rC_Giving__Is_Restricted__c,rC_Giving__Is_Selected__c,
	rC_Giving__Is_Shopper__c,rC_Giving__Is_Suspended__c,rC_Giving__Is_Sustainer__c,rC_Giving__Is_Tribute__c,rC_Giving__Is_Uncollectible__c,rC_Giving__Last_Giving_Amount_Adjustment__c,
	rC_Giving__Last_Giving_Amount_Adjustment_Date__c,rC_Giving__Letter_Of_Intent_Deadline__c,rC_Giving__Link_2__c,rC_Giving__Link_3__c,rC_Giving__Link_4__c,rC_Giving__Link_5__c,rC_Giving__Link_6__c,
	rC_Giving__Matching_Account__c,rC_Giving__Matching_Amount__c,rC_Giving__Matching_Notice__c,rC_Giving__Matching_Opportunity__c,rC_Giving__Matching_Status__c,rC_Giving__Media_Amount_1__c,
	rC_Giving__Media_Amount_2__c,rC_Giving__Media_Amount_3__c,rC_Giving__Media_Amount_4__c,rC_Giving__Media_Amount_5__c,rC_Giving__Media_Type_1__c,rC_Giving__Media_Type_2__c,rC_Giving__Media_Type_3__c,
	rC_Giving__Media_Type_4__c,rC_Giving__Media_Type_5__c,rC_Giving__Notice_Of_Grant_Awarded_Date__c,rC_Giving__Number_Of_Shares__c,rC_Giving__Omitted_Amount__c,rC_Giving__Omitted_Bar__c,
	rC_Giving__Omitted_Ratio__c,rC_Giving__Original_Summary__c,rC_Giving__Parent__c,rC_Giving__Parent_Name__c,rC_Giving__Payer_Name__c,rC_Giving__Payment_Count__c,rC_Giving__Payment_Day__c,
	rC_Giving__Payment_End_Date__c,rC_Giving__Payment_Frequency__c,rC_Giving__Payment_Method__c,rC_Giving__Payment_Method_Selected__c,rC_Giving__Payment_Reference_Number__c,rC_Giving__Performance_Measures__c,
	rC_Giving__Pipeline_Amount__c,rC_Giving__Pipeline_Bar__c,rC_Giving__Pipeline_Ratio__c,rC_Giving__Planned_Giving__c,rC_Giving__Pre_Award_Cost_Approval__c,rC_Giving__Primary_Contact__c,
	rC_Giving__Projected_Amount__c,rC_Giving__Projected_Bar__c,rC_Giving__Projected_Ratio__c,rC_Giving__Proposed_End_Date__c,rC_Giving__Proposed_Start_Date__c,rC_Giving__Prospect_Rating__c,
	rC_Giving__Realized_Amount__c,rC_Giving__Realized_Date__c,rC_Giving__Refund_Reason__c,rC_Giving__Refunded_Amount__c,rC_Giving__Refunded_Bar__c,rC_Giving__Refunded_Ratio__c,
	rC_Giving__Renew_By_Email__c,rC_Giving__Renew_By_Postal_Mail__c,rC_Giving__Reporting_Schedule__c,rC_Giving__Requested_Amount__c,rC_Giving__Response_Mechanism__c,rC_Giving__Retention_Rate__c,
	rC_Giving__Rollup_Allocations__c,rC_Giving__Rollup_Giving__c,rC_Giving__Rollup_Transactions__c,rC_Giving__Solicitation_Status__c,rC_Giving__Solicitation_Type__c,rC_Giving__Sorting_Number__c,
	rC_Giving__Source_Code__c,rC_Giving__Summary__c,rC_Giving__Summary_Link__c,rC_Giving__Support_Designation__c,rC_Giving__Suspended_End_Date__c,rC_Giving__Suspended_Start_Date__c,
	rC_Giving__Tax_Deductible_Amount__c,rC_Giving__Ticker_Symbol__c,rC_Giving__Transaction_Type__c,rC_Giving__Tribute_Comments__c,rC_Giving__Tribute_Contact__c,rC_Giving__Tribute_Delivered_Date__c,
	rC_Giving__Tribute_Delivery__c,rC_Giving__Tribute_Description__c,rC_Giving__Tribute_Effective_Date__c,rC_Giving__Tribute_Name__c,rC_Giving__Tribute_Type__c,rC_Giving__Update_Transactions__c,
	rC_Giving__Valuation_Date__c,rC_Giving__Valuation_Type__c,RE_Date_and_Ext_ID__c,RecordTypeId,Special_Gift_Indicator__c,StageName,State_Commission__c,State_Commission_Contact__c,SystemModstamp,
	Team_Weekly_Schedule__c,Tier__c,TotalOpportunityQuantity,Type,X30_Day_Enrollment_Compliance_Late__c,X30_Day_Exit_Compliance_Late__c, Workday_Integration_Datetime_Stamp__c
	from ODW.dbo.[DimHardCredit_Allocation] (nolock)
	inner join (select distinct ID, AccountID, CampaignId from ODW_Stage.dbo.Opportunity_Full (nolock)) a ON
		[DimHardCredit_Allocation].Opportunity = a.Id
	inner join ODW.dbo.DimAccount (nolock) on
		a.AccountId = DimAccount.[Account Id]
	left outer join (select distinct AccountID from ODW_Stage.dbo.Contact (nolock)) c on
		DimAccount.[Account Id] = c.AccountId
	inner join ODW_Stage.dbo.Opportunity_Full (nolock) d on a.ID = d.ID

	-- where RecordTypeId <> '012U000000017QTIAY'

	insert into ODW.dbo.DimRJSMembership([Account],[Comments],[Received Connection ID],[Sent Connection ID],[Created By ID],[Created Date],[Fiscal Year],[Record ID],[Deleted],[Last Activity Date],[Last Modified By ID],[Last Modified Date],[Level],[Reference #],[Qualification Date],[Site Affiliation], [Society],[System Modstamp],[Type])
	select Account__c,Comments__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Fiscal_Year__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Level__c,Name,Qualification_Date__c,Site_Affiliation__c,Society__c,SystemModstamp,Type__c from ODW_Stage.dbo.RJS_Membership__c (nolock)

	update ODW.dbo.DimAccountRelationship
	set [Account Name no Household From] = b.[Account Name no Household]
	from ODW.dbo.DimAccountRelationship (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account From] = b.[Account ID]

	update ODW.dbo.DimAccountRelationship
	set [Account Name no Household To] = b.[Account Name no Household]
	from ODW.dbo.DimAccountRelationship (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account To] = b.[Account ID]

	update ODW.dbo.DimAccountRelationship
	set [Full Name To] = b.[Full Name]
	from ODW.dbo.DimAccountRelationship (nolock) a
	inner join ODW.dbo.DimContact (nolock) b on a.[Contact To] = b.[Contact ID]

	update ODW.dbo.DimAccountRelationship
	set [Full Name From] = b.[Full Name]
	from ODW.dbo.DimAccountRelationship (nolock) a
	inner join ODW.dbo.DimContact (nolock) b on a.[Contact From] = b.[Contact ID]

	update ODW.dbo.DimContactRelationship
	set [Account Name no Household From] = b.[Account Name no Household]
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account From] = b.[Account ID]

	update ODW.dbo.DimContactRelationship
	set [Account Name no Household To] = b.[Account Name no Household]
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account To] = b.[Account ID]

	update ODW.dbo.DimContactRelationship
	set [Full Name To] = b.[Full Name]
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join ODW.dbo.DimContact (nolock) b on a.[Contact To] = b.[Contact ID]

	update ODW.dbo.DimContactRelationship
	set [Full Name From] = b.[Full Name]
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join ODW.dbo.DimContact (nolock) b on a.[Contact From] = b.[Contact ID]


	update ODW.dbo.DimContact
	set [Preferred Email Value] = 
	case [Preferred Email]
		WHEN 'Assistant' then [Assistant Email]
		WHEN 'Home' then [Home Email]
		WHEN 'Other' then [Other Email]
		WHEN 'Work' then [WOrk Email]
		Else 'N/A'
	end

	update ODW.dbo.DimContact
	set [Preferred Phone Value] = 
	case [Preferred Phone]
		WHEN 'Assistant' then isnull(isnull(isnull([Home Phone], [Mobile Phone]), [Work Phone]), [Other Phone])
		WHEN 'Home' then [Home Phone]
		WHEN 'Mobile' then [Mobile Phone]
		WHEN 'Other' then [Other Phone]
		WHEN 'Work' then [WOrk Phone]
		Else 'N/A'
	end

	update ODW.dbo.DimCampaignContact
	set [Preferred Email Value] = 
	case [Preferred Email]
		WHEN 'Assistant' then [Assistant Email]
		WHEN 'Home' then [Home Email]
		WHEN 'Other' then [Other Email]
		WHEN 'Work' then [WOrk Email]
		Else 'N/A'
	end

	update ODW.dbo.DimCampaignContact
	set [Preferred Phone Value] = 
	case [Preferred Phone]
		WHEN 'Assistant' then isnull(isnull(isnull([Home Phone], [Mobile Phone]), [Work Phone]), [Other Phone])
		WHEN 'Home' then [Home Phone]
		WHEN 'Mobile' then [Mobile Phone]
		WHEN 'Other' then [Other Phone]
		WHEN 'Work' then [WOrk Phone]
		Else 'N/A'
	end


	select a.AccountID, FY_Hard, sum(Hard) Hard
	into #Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join DimCampaign (nolock) c on a.OppCampaignID = c.[Campaign ID]
	where Hard > 0 and cast(substring(FY_Hard, 3, 2) as int) in (10,11,12,13,14,15)
	and	c.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and a.Stage not in ('Canceled','Suspended','Uncollectible')
	group by a.AccountID, FY_Hard, FY_Soft
	order by AccountID, FY_Hard, FY_Soft


	update ODW.dbo.DimAccount set [Hard (FY10)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY10'

	update ODW.dbo.DimAccount set [Hard (FY11)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY11'

	update ODW.dbo.DimAccount set [Hard (FY12)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY12'

	update ODW.dbo.DimAccount set [Hard (FY13)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY13'

	update ODW.dbo.DimAccount set [Hard (FY14)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY14'

	update ODW.dbo.DimAccount set [Hard (FY15)] = Hard from ODW.dbo.DimAccount (nolock) a 
	inner join #Hard (nolock) b on a.AccountID = b.AccountID
	where b.FY_Hard = 'FY15'



	select a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '') [CY Allocation Location String], 
	count(distinct OpportunityID) #OfOpps
	into #NumberOfOpportunities2
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	where Hard > 0 and cast(substring(FY_Hard, 3, 2) as int) in (14)
	group by a.AccountID, a.[Account ID], [CY Allocation Location String], FY_Hard
	order by AccountID
	
	select a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '') [CY Allocation Location String], 
	sum(Hard) Hard
	into #Hard3
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join DimCampaign (nolock) c on a.OppCampaignID = c.[Campaign ID]
	where Hard > 0 and cast(substring(FY_Hard, 3, 2) as int) in (14)
	and	c.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and a.Stage not in ('Canceled','Suspended','Uncollectible')
	group by a.AccountID, FY_Hard, [CY Allocation Location String]
	
	select a.AccountID, FY_Soft, replace([CY Allocation Location String], 'City Year ', '') [CY Allocation Location String], 
	sum(Soft) Hard
	into #Soft2
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	where isnull(Soft, 0) > 0 and FY_Soft = '2014'
	group by a.AccountID, FY_Soft, [CY Allocation Location String]

	select AccountID, FY_Hard, [CY Allocation Location String], sum(Hard) Hard
	into #Hard2
	from 
	(select * from #Hard3 (nolock)) a
	group by AccountID, FY_Hard, [CY Allocation Location String]
	
	select a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '') [CY Allocation Location String], 
	sum(Hard) Hard
	into #Hard_Boston
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join DimCampaign (nolock) c on a.OppCampaignID = c.[Campaign ID]
	where Hard > 0 and cast(substring(FY_Hard, 3, 2) as int) in (5, 6, 7, 8, 9, 10, 11, 12, 13, 15) and replace([CY Allocation Location String], 'City Year ', '') = 'Boston'
	and	c.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and a.Stage not in ('Canceled','Suspended','Uncollectible')
	group by a.AccountID, FY_Hard, [CY Allocation Location String]

	truncate table DimAccountRecentHistory
	insert into DimAccountRecentHistory(AccountID) select distinct AccountID from DimAccount (nolock) order by AccountID

	update DimAccountRecentHistory
	set [BR_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Baton Rouge'

	update DimAccountRecentHistory
	set [BOS_HC_FY05] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY05'

	update DimAccountRecentHistory
	set [BOS_HC_FY06] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY06'

	update DimAccountRecentHistory
	set [BOS_HC_FY07] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY07'

	update DimAccountRecentHistory
	set [BOS_HC_FY08] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY08'

	update DimAccountRecentHistory
	set [BOS_HC_FY09] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY09'

	update DimAccountRecentHistory
	set [BOS_HC_FY10] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY10'

	update DimAccountRecentHistory
	set [BOS_HC_FY11] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY11'

	update DimAccountRecentHistory
	set [BOS_HC_FY12] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY12'

	update DimAccountRecentHistory
	set [BOS_HC_FY13] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY13'

	update DimAccountRecentHistory
	set [BOS_HC_FY15] = b.Hard
	from DimAccountRecentHistory a inner join #Hard_Boston b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston' and FY_Hard = 'FY15'

	update DimAccountRecentHistory
	set [BOS_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Boston'

	update DimAccountRecentHistory
	set [CF_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'CareForce'

	update DimAccountRecentHistory
	set [CHI_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Chicago'

	update DimAccountRecentHistory
	set [CLE_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Cleveland'

	update DimAccountRecentHistory
	set [CIA_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Columbia'

	update DimAccountRecentHistory
	set [CUS_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Columbus'

	update DimAccountRecentHistory
	set [DEN_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Denver'

	update DimAccountRecentHistory
	set [DET_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Detroit'

	update DimAccountRecentHistory
	set [HQ_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Headquarters'

	update DimAccountRecentHistory
	set [JAX_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Jacksonville'

	update DimAccountRecentHistory
	set [LR_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Little Rock'

	update DimAccountRecentHistory
	set [LA_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Los Angeles'

	update DimAccountRecentHistory
	set [LOU_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Louisiana'

	update DimAccountRecentHistory
	set [MIA_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Miami'

	update DimAccountRecentHistory
	set [MIL_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Milwaukee'

	update DimAccountRecentHistory
	set [NH_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'New Hampshire'

	update DimAccountRecentHistory
	set [NO_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'New Orleans'

	update DimAccountRecentHistory
	set [NYC_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'New York City'

	update DimAccountRecentHistory
	set [ORL_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Orlando'

	update DimAccountRecentHistory
	set [PHI_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Philadelphia'

	update DimAccountRecentHistory
	set [RI_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Rhode Island'

	update DimAccountRecentHistory
	set [SAC_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Sacramento'

	update DimAccountRecentHistory
	set [SA_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'San Antonio'

	update DimAccountRecentHistory
	set [SJ_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'San Jose'

	update DimAccountRecentHistory
	set [SEA_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Seattle'

	update DimAccountRecentHistory
	set [TUL_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Tulsa'

	update DimAccountRecentHistory
	set [WASH_HC] = b.Hard
	from DimAccountRecentHistory a inner join #Hard2 b on a.AccountID = b.AccountID 
	where b.[CY Allocation Location String] = 'Washington DC'


	update DImAccount set [Soft (FY10)] = 0 where [Soft (FY10)] is null
	update DImAccount set [Soft (FY11)] = 0 where [Soft (FY11)] is null
	update DImAccount set [Soft (FY12)] = 0 where [Soft (FY12)] is null
	update DImAccount set [Soft (FY13)] = 0 where [Soft (FY13)] is null
	update DImAccount set [Soft (FY14)] = 0 where [Soft (FY14)] is null
	update DImAccount set [Soft (FY15)] = 0 where [Soft (FY15)] is null

	update DImAccount set [Hard (FY10)] = 0 where [Hard (FY10)] is null
	update DImAccount set [Hard (FY11)] = 0 where [Hard (FY11)] is null
	update DImAccount set [Hard (FY12)] = 0 where [Hard (FY12)] is null
	update DImAccount set [Hard (FY13)] = 0 where [Hard (FY13)] is null
	update DImAccount set [Hard (FY14)] = 0 where [Hard (FY14)] is null
	update DImAccount set [Hard (FY15)] = 0 where [Hard (FY15)] is null

	update DImAccount set [Total (FY10)] = 0 where [Total (FY10)] is null
	update DImAccount set [Total (FY11)] = 0 where [Total (FY11)] is null
	update DImAccount set [Total (FY12)] = 0 where [Total (FY12)] is null
	update DImAccount set [Total (FY13)] = 0 where [Total (FY13)] is null
	update DImAccount set [Total (FY14)] = 0 where [Total (FY14)] is null
	update DImAccount set [Total (FY15)] = 0 where [Total (FY15)] is null

	update DimAccountRecentHistory set BR_HC  = 0 where BR_HC  is null
	update DimAccountRecentHistory set BOS_HC_FY05  = 0 where BOS_HC_FY05 is null
	update DimAccountRecentHistory set BOS_HC_FY06  = 0 where BOS_HC_FY06 is null
	update DimAccountRecentHistory set BOS_HC_FY07  = 0 where BOS_HC_FY07 is null
	update DimAccountRecentHistory set BOS_HC_FY08  = 0 where BOS_HC_FY08 is null
	update DimAccountRecentHistory set BOS_HC_FY09  = 0 where BOS_HC_FY09 is null
	update DimAccountRecentHistory set BOS_HC_FY10  = 0 where BOS_HC_FY10 is null
	update DimAccountRecentHistory set BOS_HC_FY11  = 0 where BOS_HC_FY11 is null
	update DimAccountRecentHistory set BOS_HC_FY12  = 0 where BOS_HC_FY12 is null
	update DimAccountRecentHistory set BOS_HC_FY13  = 0 where BOS_HC_FY13 is null
	update DimAccountRecentHistory set BOS_HC_FY15  = 0 where BOS_HC_FY15 is null
	update DimAccountRecentHistory set BOS_HC  = 0 where BOS_HC  is null
	update DimAccountRecentHistory set CF_HC  = 0 where CF_HC  is null
	update DimAccountRecentHistory set CHI_HC  = 0 where CHI_HC  is null
	update DimAccountRecentHistory set CLE_HC  = 0 where CLE_HC  is null
	update DimAccountRecentHistory set CIA_HC  = 0 where CIA_HC  is null
	update DimAccountRecentHistory set CUS_HC  = 0 where CUS_HC  is null
	update DimAccountRecentHistory set DEN_HC  = 0 where DEN_HC  is null
	update DimAccountRecentHistory set DET_HC  = 0 where DET_HC  is null
	update DimAccountRecentHistory set HQ_HC  = 0 where HQ_HC  is null
	update DimAccountRecentHistory set JAX_HC  = 0 where JAX_HC  is null
	update DimAccountRecentHistory set LR_HC  = 0 where LR_HC  is null
	update DimAccountRecentHistory set LA_HC  = 0 where LA_HC  is null
	update DimAccountRecentHistory set LOU_HC  = 0 where LOU_HC  is null
	update DimAccountRecentHistory set MIA_HC  = 0 where MIA_HC  is null
	update DimAccountRecentHistory set MIL_HC  = 0 where MIL_HC  is null
	update DimAccountRecentHistory set NH_HC  = 0 where NH_HC  is null
	update DimAccountRecentHistory set NO_HC  = 0 where NO_HC  is null
	update DimAccountRecentHistory set NYC_HC  = 0 where NYC_HC  is null
	update DimAccountRecentHistory set ORL_HC  = 0 where ORL_HC  is null
	update DimAccountRecentHistory set PHI_HC  = 0 where PHI_HC  is null
	update DimAccountRecentHistory set RI_HC  = 0 where RI_HC  is null
	update DimAccountRecentHistory set SAC_HC  = 0 where SAC_HC  is null
	update DimAccountRecentHistory set SA_HC  = 0 where SA_HC  is null
	update DimAccountRecentHistory set SJ_HC  = 0 where SJ_HC  is null
	update DimAccountRecentHistory set SEA_HC  = 0 where SEA_HC  is null
	update DimAccountRecentHistory set TUL_HC  = 0 where TUL_HC  is null
	update DimAccountRecentHistory set WASH_HC  = 0 where WASH_HC  is null

END

GO
