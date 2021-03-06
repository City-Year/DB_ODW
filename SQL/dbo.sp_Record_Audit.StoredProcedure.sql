USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_Record_Audit]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Record_Audit]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimAccount' as TableName, count(*), getdate() from ODW.dbo.DimAccount (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimAccountRelationship' as TableName, count(*), getdate() from ODW.dbo.DimAccountRelationship (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosAccountAddress' as TableName, count(*), getdate() from ODW.dbo.DimBiosAccountAddress (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosAccountPreferences' as TableName, count(*), getdate() from ODW.dbo.DimBiosAccountPreferences (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosAccountSalutation' as TableName, count(*), getdate() from ODW.dbo.DimBiosAccountSalutation (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosAddress' as TableName, count(*), getdate() from ODW.dbo.DimBiosAddress (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosContactAddress' as TableName, count(*), getdate() from ODW.dbo.DimBiosContactAddress (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosContactPreferences' as TableName, count(*), getdate() from ODW.dbo.DimBiosContactPreferences (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimBiosContactSalutation' as TableName, count(*), getdate() from ODW.dbo.DimBiosContactSalutation (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimCampaign' as TableName, count(*), getdate() from ODW.dbo.DimCampaign (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimCampaignContact' as TableName, count(*), getdate() from ODW.dbo.DimCampaignContact (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimCampaignMember' as TableName, count(*), getdate() from ODW.dbo.DimCampaignMember (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimContact' as TableName, count(*), getdate() from ODW.dbo.DimContact (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimContactRelationship' as TableName, count(*), getdate() from ODW.dbo.DimContactRelationship (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimCreditAccount' as TableName, count(*), getdate() from ODW.dbo.DimCreditAccount (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimHardCredit_Allocation' as TableName, count(*), getdate() from ODW.dbo.DimHardCredit_Allocation (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimRelationship' as TableName, count(*), getdate() from ODW.dbo.DimRelationship (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'DimSoftCredit' as TableName, count(*), getdate() from ODW.dbo.DimSoftCredit (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'FactDonor' as TableName, count(*), getdate() from ODW.dbo.FactDonor (nolock)

insert into ODW.dbo.Record_Audit(TableName, Count, [Date])
select 'FactDonor_Full' as TableName, count(*), getdate() from ODW.dbo.FactDonor_Full (nolock)

END

GO
