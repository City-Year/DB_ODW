USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_3a_Update_Historical_Giving]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_3a_Update_Historical_Giving]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @Boston_Recent_Start as date
	declare @Boston_Recent_End as date
	set @Boston_Recent_Start = cast('11/26/2014' as date)
	set @Boston_Recent_End = cast('12/5/2014' as date)


-- STEP ONE  INSERT ACCOUNT ID's TO TABLE FOR EACH FY

	Truncate table ODW.Recent_History.DimTotalGiving
	Truncate table Recent_History.DimRecentGivingFY05
	Truncate table Recent_History.DimRecentGivingFY06
	Truncate table Recent_History.DimRecentGivingFY07
	Truncate table Recent_History.DimRecentGivingFY08
	Truncate table Recent_History.DimRecentGivingFY09
	Truncate table Recent_History.DimRecentGivingFY10
	Truncate table Recent_History.DimRecentGivingFY11
	Truncate table Recent_History.DimRecentGivingFY12
	Truncate table Recent_History.DimRecentGivingFY13
	Truncate table Recent_History.DimRecentGivingFY14
	Truncate table Recent_History.DimRecentGivingFY15
	Truncate table Recent_History.DimRecentGivingFY16
	Truncate table Recent_History.DimRecentGivingFY17
	Truncate table Recent_History.DimRecentGivingFY18
	Truncate table Recent_History.DimRecentGivingFY19
	Truncate table Recent_History.DimRecentGivingFY20

	select AccountID, Account, BusinessUnit, [Fiscal Year], sum(Soft) Soft, sum(Soft1) Soft1, suM(Soft2) Soft2
	into #Soft1
	from 
	(select b.[Opportunity ID], a.[Reference #], count(b.[Opportunity ID]) [Count], d.AccountID, Account, 
	c.[General Accounting Unit Name] BusinessUnit, c.[Fiscal Year], 
	0 as Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) / count(b.[Opportunity ID]) as Soft2
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	and b.[Record Type ID] <> '012U000000017QTIAY'
	group by b.[Opportunity ID], a.[Reference #], d.AccountID, Account, c.[General Accounting Unit Name], 
	c.[Fiscal Year]) a
	group by AccountID, Account, BusinessUnit, [Fiscal Year]

	update #Soft1 set Soft = Soft1 where Soft1 < Soft2
	update #Soft1 set Soft = Soft2 where Soft1 >= Soft2

	select b.[AccountID], 
	c.[General Accounting Unit Name] as BusinessUnit, 
	c.[Fiscal Year],
	sum(c.[Proposal Amount]) PandT, 
	sum(case a.Stage when 'DV Promised and Thanked' then c.[Weighted Proposal Amount] else 0 end) PandTWeighted
	into #PandT
	from ODW.dbo.FactDonor_Full (nolock) a 
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join ODW.dbo.DimHardCredit_Allocation (nolock) c on a.AllocationID = c.HardCreditID
	where 
	--c.[Fiscal Year] in ('FY15') and 
	isnull(a.Tier, 'N/A') not in ('Tier 5') 
	and a.Stage in ('DV Promised and Thanked')
	and a.[Record Type ID] <> '012U000000017QTIAY'
	--and cast(a.[Close Date] as date) >= cast('7/1/2014' as date) 
	--and cast('6/30/2015' as date)
	group by c.[General Accounting Unit Name], b.[AccountID], c.[Fiscal Year]
	order by b.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]

	select b.AccountID, a.BusinessUnit, a.[Fiscal Year], sum(ProposalAmount) GIT
	into #GIT
	from [FinancialReporting].[dbo].[RPT6_Gifts] (nolock) a 
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.[Account ID]
	group by b.AccountID, a.BusinessUnit, a.[Fiscal Year]
	
	select b.[AccountID], 
	c.[General Accounting Unit Name] as BusinessUnit, 
	c.[Fiscal Year],
	sum(c.[Proposal Amount]) Stewardship
	into #Stewardship
	from ODW.dbo.FactDonor_Full (nolock) a 
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join ODW.dbo.DimHardCredit_Allocation (nolock) c on a.AllocationID = c.HardCreditID
	where 
	--c.[Fiscal Year] in ('FY15') and 
	isnull(a.Tier, 'N/A') not in ('Tier 5') 
	and a.Stage in ('DV Stewardship')
	and a.[Record Type ID] = '012U000000017QWIAY'
	--and cast(a.[Close Date] as date) >= cast('7/1/2014' as date) 
	--and cast('6/30/2015' as date)
	group by c.[General Accounting Unit Name], b.[AccountID], c.[Fiscal Year]
	order by b.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]

	select distinct AccountID, BusinessUnit, [Fiscal Year]
	into #ALL_Credits
	from
	(select a.AccountID, FY_Hard [Fiscal Year], replace([CY Allocation Location String], 'City Year ', '') [BusinessUnit], 
	sum(Hard) Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	where Hard > 0 
	and a.[Record Type ID] <> '012U000000017QTIAY'
	group by a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '')
	UNION ALL
	select AccountID, [Fiscal Year], BusinessUnit, Soft from #Soft1
	UNION ALL
	select AccountID, [Fiscal Year], BusinessUnit, PandT from #PandT where PandT > 0
	UNION ALL
	select AccountID, [Fiscal Year], BusinessUnit, GIT from #GIT where GIT > 0) a
	order by AccountID, BusinessUnit, [Fiscal Year]
	-- 103,837

	truncate table ODW.dbo.DimAccountGivingHistory

	insert into ODW.dbo.DimAccountGivingHistory(AccountID, Site, Year)
	select AccountID, BusinessUnit, [Fiscal Year] from #ALL_Credits
	-- 11,438

	select a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '') [BusinessUnit], 
	sum(Hard) Hard
	into #Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join DimCampaign (nolock) e on a.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and a.Stage not in ('Canceled','Suspended','Uncollectible')
	and Hard > 0 
	and a.[Record Type ID] <> '012U000000017QTIAY'
	group by a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '')
	-- 97,437

/*
	select d.AccountID, c.[General Accounting Unit Name] BusinessUnit, 
	c.[Fiscal Year], sum(c.[Amount]) Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #Soft
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	group by d.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]
	order by [Fiscal Year]
	-- 7,975

	update #Soft set Soft = Soft1 where Soft1 < Soft2
	update #Soft set Soft = Soft2 where Soft1 >= Soft2
*/

	select AccountID, Account, BusinessUnit, [Fiscal Year], sum(Soft) Soft, sum(Soft1) Soft1, suM(Soft2) Soft2
	into #Soft
	from 
	(select b.[Opportunity ID], a.[Reference #], count(b.[Opportunity ID]) [Count], d.AccountID, Account, 
	c.[General Accounting Unit Name] BusinessUnit, c.[Fiscal Year], 
	0 as Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) / count(b.[Opportunity ID]) as Soft2
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	and b.[Record Type ID] <> '012U000000017QTIAY'
	group by b.[Opportunity ID], a.[Reference #], d.AccountID, Account, c.[General Accounting Unit Name], 
	c.[Fiscal Year]) a
	group by AccountID, Account, BusinessUnit, [Fiscal Year]

	update #Soft set Soft = Soft1 where Soft1 < Soft2
	update #Soft set Soft = Soft2 where Soft1 >= Soft2

	
	update ODW.dbo.DimAccountGivingHistory
	set Soft = b.Soft 
	from ODW.dbo.DimAccountGivingHistory (nolock) a
	inner join #Soft (nolock) b on a.AccountID = b.AccountID and a.Site = b.BusinessUnit and a.Year = b.[Fiscal Year]

	update ODW.dbo.DimAccountGivingHistory
	set Hard = b.Hard 
	from ODW.dbo.DimAccountGivingHistory (nolock) a
	inner join #Hard (nolock) b on a.AccountID = b.AccountID and a.Site = b.BusinessUnit and a.Year = b.FY_Hard

	update ODW.dbo.DimAccountGivingHistory
	set PandT = b.PandT 
	from ODW.dbo.DimAccountGivingHistory (nolock) a
	inner join #PandT (nolock) b on a.AccountID = b.AccountID and a.Site = b.BusinessUnit and a.Year = b.[Fiscal Year]

	update ODW.dbo.DimAccountGivingHistory
	set GIT = b.GIT
	from ODW.dbo.DimAccountGivingHistory (nolock) a
	inner join #GIT (nolock) b on a.AccountID = b.AccountID and a.Site = b.BusinessUnit and a.Year = b.[Fiscal Year]

	update ODW.dbo.DimAccountGivingHistory set Soft = 0 where Soft is null
	update ODW.dbo.DimAccountGivingHistory set Hard = 0 where Hard is null
	update ODW.dbo.DimAccountGivingHistory set PandT = 0 where PandT is null
	update ODW.dbo.DimAccountGivingHistory set GIT = 0 where GIT is null
	update ODW.dbo.DimAccountGivingHistory set Total = Soft + Hard
	update ODW.dbo.DimAccountGivingHistory set [Total_With_PandT] = Total + PandT

	update ODW.dbo.DimAccountGivingHistory
	set Year_Numeric = case [Year]
		WHEN 'FY 0' THEN 2000
		WHEN 'FY00' THEN 2000
		WHEN 'FY01' THEN 2001
		WHEN 'FY02' THEN 2002
		WHEN 'FY03' THEN 2003
		WHEN 'FY04' THEN 2004
		WHEN 'FY05' THEN 2005
		WHEN 'FY06' THEN 2006
		WHEN 'FY07' THEN 2007
		WHEN 'FY08' THEN 2008
		WHEN 'FY09' THEN 2009
		WHEN 'FY10' THEN 2010
		WHEN 'FY11' THEN 2011
		WHEN 'FY12' THEN 2012
		WHEN 'FY13' THEN 2013
		WHEN 'FY14' THEN 2014
		WHEN 'FY15' THEN 2015
		WHEN 'FY16' THEN 2016
		WHEN 'FY17' THEN 2017
		WHEN 'FY18' THEN 2018
		WHEN 'FY19' THEN 2019
		WHEN 'FY20' THEN 2020
		WHEN 'FY21' THEN 2021
		WHEN 'FY22' THEN 2022
		WHEN 'FY93' THEN 1993
		WHEN 'FY94' THEN 1994
		WHEN 'FY95' THEN 1995
		WHEN 'FY96' THEN 1996
		WHEN 'FY97' THEN 1997
		WHEN 'FY98' THEN 1998
		WHEN 'FY99' THEN 1999
	END

	drop table ODW.dbo.DimCampaignContactRecentHistory

	select * 
	into ODW.dbo.DimCampaignContactRecentHistory
	from ODW.dbo.DimAccountRecentHistory (nolock)

	ALTER TABLE ODW.dbo.DimCampaignContactRecentHistory ADD FY15_Total money
	
	update ODW.dbo.DimCampaignContactRecentHistory 
	set FY15_Total = b.[Hard (FY15)] + b.[Soft (FY15)]
	from ODW.dbo.DimCampaignContactRecentHistory (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.AccountID

	INSERT INTO ODW.Recent_History.DimRecentGivingFY20(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET
	BR_HC_FY20		= b.Hard,
	BR_SC_FY20		= b.Soft,
	BR_PandT_FY20	= b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET
	BOS_HC_FY20		= b.Hard,
	BOS_SC_FY20		= b.Soft,
	BOS_PandT_FY20	= b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET
	CF_HC_FY20		= b.Hard,
	CF_SC_FY20		= b.Soft,
	CF_PandT_FY20	= b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	CHI_HC_FY20		= b.Hard, 
	CHI_SC_FY20		= b.Soft,
	CHI_PandT_FY20	= b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	CLE_HC_FY20		=  b.Hard, 
	CLE_SC_FY20		=  b.Soft,
	CLE_PandT_FY20	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	CIA_HC_FY20		=  b.Hard, 
	CIA_SC_FY20		=  b.Soft,
	CIA_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	CUS_HC_FY20		=  b.Hard, 
	CUS_SC_FY20		=  b.Soft,
	CUS_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	DAL_HC_FY20		=  b.Hard, 
	DAL_SC_FY20		=  b.Soft,
	DAL_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Dallas'


	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	DEN_HC_FY20		=  b.Hard, 
	DEN_SC_FY20		=  b.Soft,
	DEN_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	DET_HC_FY20		=  b.Hard, 
	DET_SC_FY20		=  b.Soft,
	DET_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	HQ_HC_FY20		=  b.Hard, 
	HQ_SC_FY20		=  b.Soft,
	HQ_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	JAX_HC_FY20		=  b.Hard, 
	JAX_SC_FY20		=  b.Soft,
	JAX_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	LR_HC_FY20  =  b.Hard, 
	LR_SC_FY20  =  b.Soft,
	LR_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	LA_HC_FY20  =  b.Hard, 
	LA_SC_FY20  =  b.Soft,
	LA_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	LOU_HC_FY20  =  b.Hard, 
	LOU_SC_FY20  =  b.Soft,
	LOU_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	MIA_HC_FY20  =  b.Hard, 
	MIA_SC_FY20  =  b.Soft,
	MIA_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	MIL_HC_FY20  =  b.Hard, 
	MIL_SC_FY20  =  b.Soft,
	MIL_PandT_FY20	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	NH_HC_FY20  =  b.Hard, 
	NH_SC_FY20  =  b.Soft,
	NH_PandT_FY20	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	NO_HC_FY20  =  b.Hard, 
	NO_SC_FY20  =  b.Soft,
	NO_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	NYC_HC_FY20  =  b.Hard, 
	NYC_SC_FY20  =  b.Soft,
	NYC_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	ORL_HC_FY20  =  b.Hard, 
	ORL_SC_FY20  =  b.Soft,
	ORL_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	PHI_HC_FY20  =  b.Hard, 
	PHI_SC_FY20  =  b.Soft,
	PHI_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	RI_HC_FY20  =  b.Hard, 
	RI_SC_FY20  =  b.Soft,
	RI_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	SAC_HC_FY20  =  b.Hard, 
	SAC_SC_FY20  =  b.Soft,
	SAC_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	SA_HC_FY20  =  b.Hard, 
	SA_SC_FY20  =  b.Soft,
	SA_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	SJ_HC_FY20  =  b.Hard, 
	SJ_SC_FY20  =  b.Soft,
	SJ_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	SEA_HC_FY20  =  b.Hard, 
	SEA_SC_FY20  =  b.Soft,
	SEA_PandT_FY20	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	TUL_HC_FY20  =  b.Hard, 
	TUL_SC_FY20  =  b.Soft,
	TUL_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	WASH_HC_FY20  =  b.Hard, 
	WASH_SC_FY20  =  b.Soft,
	WASH_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Washington DC'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY20 SET 
	DAL_HC_FY20  =  b.Hard, 
	DAL_SC_FY20  =  b.Soft,
	DAL_PandT_FY20	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY20  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY20'
	and b.site = 'Dallas'


	INSERT INTO ODW.Recent_History.DimRecentGivingFY19(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET
	BR_HC_FY19  = b.Hard,
	BR_SC_FY19  = b.Soft,
	BR_PandT_FY19	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET
	BOS_HC_FY19  = b.Hard,
	BOS_SC_FY19  = b.Soft,
	BOS_PandT_FY19	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET
	CF_HC_FY19  = b.Hard,
	CF_SC_FY19  = b.Soft,
	CF_PandT_FY19	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	CHI_HC_FY19  =  b.Hard, 
	CHI_SC_FY19  =  b.Soft,
	CHI_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	CLE_HC_FY19  =  b.Hard, 
	CLE_SC_FY19  =  b.Soft,
	CLE_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	CIA_HC_FY19  =  b.Hard, 
	CIA_SC_FY19  =  b.Soft,
	CIA_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	CUS_HC_FY19  =  b.Hard, 
	CUS_SC_FY19  =  b.Soft,
	CUS_PandT_FY19	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	DAL_HC_FY19  =  b.Hard, 
	DAL_SC_FY19  =  b.Soft,
	DAL_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	DEN_HC_FY19  =  b.Hard, 
	DEN_SC_FY19  =  b.Soft,
	DEN_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	DET_HC_FY19  =  b.Hard, 
	DET_SC_FY19  =  b.Soft,
	DET_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	HQ_HC_FY19  =  b.Hard, 
	HQ_SC_FY19  =  b.Soft,
	HQ_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	JAX_HC_FY19  =  b.Hard, 
	JAX_SC_FY19  =  b.Soft,
	JAX_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	LR_HC_FY19  =  b.Hard, 
	LR_SC_FY19  =  b.Soft,
	LR_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	LA_HC_FY19  =  b.Hard, 
	LA_SC_FY19  =  b.Soft,
	LA_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	LOU_HC_FY19  =  b.Hard, 
	LOU_SC_FY19  =  b.Soft,
	LOU_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	MIA_HC_FY19  =  b.Hard, 
	MIA_SC_FY19  =  b.Soft,
	MIA_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	MIL_HC_FY19  =  b.Hard, 
	MIL_SC_FY19  =  b.Soft,
	MIL_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	NH_HC_FY19  =  b.Hard, 
	NH_SC_FY19  =  b.Soft,
	NH_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	NO_HC_FY19  =  b.Hard, 
	NO_SC_FY19  =  b.Soft,
	NO_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	NYC_HC_FY19  =  b.Hard, 
	NYC_SC_FY19  =  b.Soft,
	NYC_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	ORL_HC_FY19  =  b.Hard, 
	ORL_SC_FY19  =  b.Soft,
	ORL_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	PHI_HC_FY19  =  b.Hard, 
	PHI_SC_FY19  =  b.Soft,
	PHI_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	RI_HC_FY19  =  b.Hard, 
	RI_SC_FY19  =  b.Soft,
	RI_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	SAC_HC_FY19  =  b.Hard, 
	SAC_SC_FY19  =  b.Soft,
	SAC_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	SA_HC_FY19  =  b.Hard, 
	SA_SC_FY19  =  b.Soft,
	SA_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	SJ_HC_FY19  =  b.Hard, 
	SJ_SC_FY19  =  b.Soft,
	SJ_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	SEA_HC_FY19  =  b.Hard, 
	SEA_SC_FY19  =  b.Soft,
	SEA_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	TUL_HC_FY19  =  b.Hard, 
	TUL_SC_FY19  =  b.Soft,
	TUL_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY19 SET 
	WASH_HC_FY19  =  b.Hard, 
	WASH_SC_FY19  =  b.Soft,
	WASH_PandT_FY19	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY19  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY19'
	and b.site = 'Washington DC'

	

	INSERT INTO ODW.Recent_History.DimRecentGivingFY18(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET
	BR_HC_FY18  = b.Hard,
	BR_SC_FY18  = b.Soft,
	BR_PandT_FY18	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET
	BOS_HC_FY18  = b.Hard,
	BOS_SC_FY18  = b.Soft,
	BOS_PandT_FY18	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET
	CF_HC_FY18  = b.Hard,
	CF_SC_FY18  = b.Soft,
	CF_PandT_FY18	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	CHI_HC_FY18  =  b.Hard, 
	CHI_SC_FY18  =  b.Soft,
	CHI_PandT_FY18	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	CLE_HC_FY18  =  b.Hard, 
	CLE_SC_FY18  =  b.Soft,
	CLE_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	CIA_HC_FY18  =  b.Hard, 
	CIA_SC_FY18  =  b.Soft,
	CIA_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	CUS_HC_FY18  =  b.Hard, 
	CUS_SC_FY18  =  b.Soft,
	CUS_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	DAL_HC_FY18  =  b.Hard, 
	DAL_SC_FY18  =  b.Soft,
	DAL_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	DEN_HC_FY18  =  b.Hard, 
	DEN_SC_FY18  =  b.Soft,
	DEN_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	DET_HC_FY18  =  b.Hard, 
	DET_SC_FY18  =  b.Soft,
	DET_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	HQ_HC_FY18  =  b.Hard, 
	HQ_SC_FY18  =  b.Soft,
	HQ_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	JAX_HC_FY18  =  b.Hard, 
	JAX_SC_FY18  =  b.Soft,
	JAX_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	LR_HC_FY18  =  b.Hard, 
	LR_SC_FY18  =  b.Soft,
	LR_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	LA_HC_FY18  =  b.Hard, 
	LA_SC_FY18  =  b.Soft,
	LA_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	LOU_HC_FY18  =  b.Hard, 
	LOU_SC_FY18  =  b.Soft,
	LOU_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	MIA_HC_FY18  =  b.Hard, 
	MIA_SC_FY18  =  b.Soft,
	MIA_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	MIL_HC_FY18  =  b.Hard, 
	MIL_SC_FY18  =  b.Soft,
	MIL_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	NH_HC_FY18  =  b.Hard, 
	NH_SC_FY18  =  b.Soft,
	NH_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	NO_HC_FY18  =  b.Hard, 
	NO_SC_FY18  =  b.Soft,
	NO_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	NYC_HC_FY18  =  b.Hard, 
	NYC_SC_FY18  =  b.Soft,
	NYC_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	ORL_HC_FY18  =  b.Hard, 
	ORL_SC_FY18  =  b.Soft,
	ORL_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	PHI_HC_FY18  =  b.Hard, 
	PHI_SC_FY18  =  b.Soft,
	PHI_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	RI_HC_FY18  =  b.Hard, 
	RI_SC_FY18  =  b.Soft,
	RI_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	SAC_HC_FY18  =  b.Hard, 
	SAC_SC_FY18  =  b.Soft,
	SAC_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	SA_HC_FY18  =  b.Hard, 
	SA_SC_FY18  =  b.Soft,
	SA_PandT_FY18	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	SJ_HC_FY18  =  b.Hard, 
	SJ_SC_FY18  =  b.Soft,
	SJ_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	SEA_HC_FY18  =  b.Hard, 
	SEA_SC_FY18  =  b.Soft,
	SEA_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	TUL_HC_FY18  =  b.Hard, 
	TUL_SC_FY18  =  b.Soft,
	TUL_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY18 SET 
	WASH_HC_FY18  =  b.Hard, 
	WASH_SC_FY18  =  b.Soft,
	WASH_PandT_FY18	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY18  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY18'
	and b.site = 'Washington DC'

	

	INSERT INTO ODW.Recent_History.DimRecentGivingFY17(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET
	BR_HC_FY17  = b.Hard,
	BR_SC_FY17  = b.Soft,
	BR_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET
	BOS_HC_FY17  = b.Hard,
	BOS_SC_FY17  = b.Soft,
	BOS_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET
	CF_HC_FY17  = b.Hard,
	CF_SC_FY17  = b.Soft,
	CF_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	CHI_HC_FY17  =  b.Hard, 
	CHI_SC_FY17  =  b.Soft,
	CHI_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	CLE_HC_FY17  =  b.Hard, 
	CLE_SC_FY17  =  b.Soft,
	CLE_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	CIA_HC_FY17  =  b.Hard, 
	CIA_SC_FY17  =  b.Soft,
	CIA_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	CUS_HC_FY17  =  b.Hard, 
	CUS_SC_FY17  =  b.Soft,
	CUS_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	DAL_HC_FY17  =  b.Hard, 
	DAL_SC_FY17  =  b.Soft,
	DAL_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	DEN_HC_FY17  =  b.Hard, 
	DEN_SC_FY17  =  b.Soft,
	DEN_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	DET_HC_FY17  =  b.Hard, 
	DET_SC_FY17  =  b.Soft,
	DET_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	HQ_HC_FY17  =  b.Hard, 
	HQ_SC_FY17  =  b.Soft,
	HQ_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	JAX_HC_FY17  =  b.Hard, 
	JAX_SC_FY17  =  b.Soft,
	JAX_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	LR_HC_FY17  =  b.Hard, 
	LR_SC_FY17  =  b.Soft,
	LR_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	LA_HC_FY17  =  b.Hard, 
	LA_SC_FY17  =  b.Soft,
	LA_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	LOU_HC_FY17  =  b.Hard, 
	LOU_SC_FY17  =  b.Soft,
	LOU_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	MIA_HC_FY17  =  b.Hard, 
	MIA_SC_FY17  =  b.Soft,
	MIA_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	MIL_HC_FY17  =  b.Hard, 
	MIL_SC_FY17  =  b.Soft,
	MIL_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	NH_HC_FY17  =  b.Hard, 
	NH_SC_FY17  =  b.Soft,
	NH_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	NO_HC_FY17  =  b.Hard, 
	NO_SC_FY17  =  b.Soft,
	NO_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	NYC_HC_FY17  =  b.Hard, 
	NYC_SC_FY17  =  b.Soft,
	NYC_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	ORL_HC_FY17  =  b.Hard, 
	ORL_SC_FY17  =  b.Soft,
	ORL_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	PHI_HC_FY17  =  b.Hard, 
	PHI_SC_FY17  =  b.Soft,
	PHI_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	RI_HC_FY17  =  b.Hard, 
	RI_SC_FY17  =  b.Soft,
	RI_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	SAC_HC_FY17  =  b.Hard, 
	SAC_SC_FY17  =  b.Soft,
	SAC_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	SA_HC_FY17  =  b.Hard, 
	SA_SC_FY17  =  b.Soft,
	SA_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	SJ_HC_FY17  =  b.Hard, 
	SJ_SC_FY17  =  b.Soft,
	SJ_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	SEA_HC_FY17  =  b.Hard, 
	SEA_SC_FY17  =  b.Soft,
	SEA_PandT_FY17	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	TUL_HC_FY17  =  b.Hard, 
	TUL_SC_FY17  =  b.Soft,
	TUL_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY17 SET 
	WASH_HC_FY17  =  b.Hard, 
	WASH_SC_FY17  =  b.Soft,
	WASH_PandT_FY17	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY17  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY17'
	and b.site = 'Washington DC'

	

	INSERT INTO ODW.Recent_History.DimRecentGivingFY16(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET
	BR_HC_FY16  = b.Hard,
	BR_SC_FY16  = b.Soft,
	BR_PandT_FY16	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET
	BOS_HC_FY16  = b.Hard,
	BOS_SC_FY16  = b.Soft,
	BOS_PandT_FY16	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET
	CF_HC_FY16  = b.Hard,
	CF_SC_FY16  = b.Soft,
	CF_PandT_FY16	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	CHI_HC_FY16  =  b.Hard, 
	CHI_SC_FY16  =  b.Soft,
	CHI_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	CLE_HC_FY16  =  b.Hard, 
	CLE_SC_FY16  =  b.Soft,
	CLE_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	CIA_HC_FY16  =  b.Hard, 
	CIA_SC_FY16  =  b.Soft,
	CIA_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	CUS_HC_FY16  =  b.Hard, 
	CUS_SC_FY16  =  b.Soft,
	CUS_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	DAL_HC_FY16  =  b.Hard, 
	DAL_SC_FY16  =  b.Soft,
	DAL_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	DEN_HC_FY16  =  b.Hard, 
	DEN_SC_FY16  =  b.Soft,
	DEN_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	DET_HC_FY16  =  b.Hard, 
	DET_SC_FY16  =  b.Soft,
	DET_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	HQ_HC_FY16  =  b.Hard, 
	HQ_SC_FY16  =  b.Soft,
	HQ_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	JAX_HC_FY16  =  b.Hard, 
	JAX_SC_FY16  =  b.Soft,
	JAX_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	LR_HC_FY16  =  b.Hard, 
	LR_SC_FY16  =  b.Soft,
	LR_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	LA_HC_FY16  =  b.Hard, 
	LA_SC_FY16  =  b.Soft,
	LA_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	LOU_HC_FY16  =  b.Hard, 
	LOU_SC_FY16  =  b.Soft,
	LOU_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	MIA_HC_FY16  =  b.Hard, 
	MIA_SC_FY16  =  b.Soft,
	MIA_PandT_FY16	=  b.PandT
	 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	MIL_HC_FY16  =  b.Hard, 
	MIL_SC_FY16  =  b.Soft,
	MIL_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	NH_HC_FY16  =  b.Hard, 
	NH_SC_FY16  =  b.Soft,
	NH_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	NO_HC_FY16  =  b.Hard, 
	NO_SC_FY16  =  b.Soft,
	NO_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	NYC_HC_FY16  =  b.Hard, 
	NYC_SC_FY16  =  b.Soft,
	NYC_PandT_FY16	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	ORL_HC_FY16  =  b.Hard, 
	ORL_SC_FY16  =  b.Soft,
	ORL_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	PHI_HC_FY16  =  b.Hard, 
	PHI_SC_FY16  =  b.Soft,
	PHI_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	RI_HC_FY16  =  b.Hard, 
	RI_SC_FY16  =  b.Soft,
	RI_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	SAC_HC_FY16  =  b.Hard, 
	SAC_SC_FY16  =  b.Soft,
	SAC_PandT_FY16	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	SA_HC_FY16  =  b.Hard, 
	SA_SC_FY16  =  b.Soft,
	SA_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	SJ_HC_FY16  =  b.Hard, 
	SJ_SC_FY16  =  b.Soft,
	SJ_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	SEA_HC_FY16  =  b.Hard, 
	SEA_SC_FY16  =  b.Soft,
	SEA_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	TUL_HC_FY16  =  b.Hard, 
	TUL_SC_FY16  =  b.Soft,
	TUL_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY16 SET 
	WASH_HC_FY16  =  b.Hard, 
	WASH_SC_FY16  =  b.Soft,
	WASH_PandT_FY16	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY16  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY16'
	and b.site = 'Washington DC'


	INSERT INTO ODW.Recent_History.DimRecentGivingFY15(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET
	BR_HC_FY15  = b.Hard,
	BR_SC_FY15  = b.Soft,
	BR_PandT_FY15	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET
	BOS_HC_FY15  = b.Hard,
	BOS_SC_FY15  = b.Soft,
	BOS_PandT_FY15	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET
	CF_HC_FY15  = b.Hard,
	CF_SC_FY15  = b.Soft,
	CF_PandT_FY15	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	CHI_HC_FY15  =  b.Hard, 
	CHI_SC_FY15  =  b.Soft,
	CHI_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	CLE_HC_FY15  =  b.Hard, 
	CLE_SC_FY15  =  b.Soft,
	CLE_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	CIA_HC_FY15  =  b.Hard, 
	CIA_SC_FY15  =  b.Soft,
	CIA_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	CUS_HC_FY15  =  b.Hard, 
	CUS_SC_FY15  =  b.Soft,
	CUS_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	DAL_HC_FY15  =  b.Hard, 
	DAL_SC_FY15  =  b.Soft,
	DAL_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	DEN_HC_FY15  =  b.Hard, 
	DEN_SC_FY15  =  b.Soft,
	DEN_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	DET_HC_FY15  =  b.Hard, 
	DET_SC_FY15  =  b.Soft,
	DET_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	HQ_HC_FY15  =  b.Hard, 
	HQ_SC_FY15  =  b.Soft,
	HQ_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	JAX_HC_FY15  =  b.Hard, 
	JAX_SC_FY15  =  b.Soft,
	JAX_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	LR_HC_FY15  =  b.Hard, 
	LR_SC_FY15  =  b.Soft,
	LR_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	LA_HC_FY15  =  b.Hard, 
	LA_SC_FY15  =  b.Soft,
	LA_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	LOU_HC_FY15  =  b.Hard, 
	LOU_SC_FY15  =  b.Soft,
	LOU_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	MIA_HC_FY15  =  b.Hard, 
	MIA_SC_FY15  =  b.Soft,
	MIA_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	MIL_HC_FY15  =  b.Hard, 
	MIL_SC_FY15  =  b.Soft,
	MIL_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	NH_HC_FY15  =  b.Hard, 
	NH_SC_FY15  =  b.Soft,
	NH_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	NO_HC_FY15  =  b.Hard, 
	NO_SC_FY15  =  b.Soft,
	NO_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	NYC_HC_FY15  =  b.Hard, 
	NYC_SC_FY15  =  b.Soft,
	NYC_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	ORL_HC_FY15  =  b.Hard, 
	ORL_SC_FY15  =  b.Soft,
	ORL_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	PHI_HC_FY15  =  b.Hard, 
	PHI_SC_FY15  =  b.Soft,
	PHI_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	RI_HC_FY15  =  b.Hard, 
	RI_SC_FY15  =  b.Soft,
	RI_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	SAC_HC_FY15  =  b.Hard, 
	SAC_SC_FY15  =  b.Soft,
	SAC_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	SA_HC_FY15  =  b.Hard, 
	SA_SC_FY15  =  b.Soft,
	SA_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	SJ_HC_FY15  =  b.Hard, 
	SJ_SC_FY15  =  b.Soft,
	SJ_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	SEA_HC_FY15  =  b.Hard, 
	SEA_SC_FY15  =  b.Soft,
	SEA_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	TUL_HC_FY15  =  b.Hard, 
	TUL_SC_FY15  =  b.Soft,
	TUL_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY15 SET 
	WASH_HC_FY15  =  b.Hard, 
	WASH_SC_FY15  =  b.Soft,
	WASH_PandT_FY15	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY15  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY15'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY14(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET
	BR_HC_FY14  = b.Hard,
	BR_SC_FY14  = b.Soft,
	BR_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET
	BOS_HC_FY14  = b.Hard,
	BOS_SC_FY14  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET
	CF_HC_FY14  = b.Hard,
	CF_SC_FY14  = b.Soft,
	CF_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	CHI_HC_FY14  =  b.Hard, 
	CHI_SC_FY14  =  b.Soft,
	CHI_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	CLE_HC_FY14  =  b.Hard, 
	CLE_SC_FY14  =  b.Soft,
	CLE_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	CIA_HC_FY14  =  b.Hard, 
	CIA_SC_FY14  =  b.Soft,
	CIA_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	CUS_HC_FY14  =  b.Hard, 
	CUS_SC_FY14  =  b.Soft,
	CUS_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Columbus'

	

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	DEN_HC_FY14  =  b.Hard, 
	DEN_SC_FY14  =  b.Soft,
	DEN_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	DET_HC_FY14  =  b.Hard, 
	DET_SC_FY14  =  b.Soft,
	DET_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	HQ_HC_FY14  =  b.Hard, 
	HQ_SC_FY14  =  b.Soft,
	HQ_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	JAX_HC_FY14  =  b.Hard, 
	JAX_SC_FY14  =  b.Soft,
	JAX_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	LR_HC_FY14  =  b.Hard, 
	LR_SC_FY14  =  b.Soft,
	LR_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	LA_HC_FY14  =  b.Hard, 
	LA_SC_FY14  =  b.Soft,
	LA_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	LOU_HC_FY14  =  b.Hard, 
	LOU_SC_FY14  =  b.Soft,
	LOU_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	MIA_HC_FY14  =  b.Hard, 
	MIA_SC_FY14  =  b.Soft,
	MIA_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	MIL_HC_FY14  =  b.Hard, 
	MIL_SC_FY14  =  b.Soft,
	MIL_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	NH_HC_FY14  =  b.Hard, 
	NH_SC_FY14  =  b.Soft,
	NH_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	NO_HC_FY14  =  b.Hard, 
	NO_SC_FY14  =  b.Soft,
	NO_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	NYC_HC_FY14  =  b.Hard, 
	NYC_SC_FY14  =  b.Soft,
	NYC_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	ORL_HC_FY14  =  b.Hard, 
	ORL_SC_FY14  =  b.Soft,
	ORL_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	PHI_HC_FY14  =  b.Hard, 
	PHI_SC_FY14  =  b.Soft,
	PHI_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	RI_HC_FY14  =  b.Hard, 
	RI_SC_FY14  =  b.Soft,
	RI_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	SAC_HC_FY14  =  b.Hard, 
	SAC_SC_FY14  =  b.Soft,
	SAC_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	SA_HC_FY14  =  b.Hard, 
	SA_SC_FY14  =  b.Soft,
	SA_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	SJ_HC_FY14  =  b.Hard, 
	SJ_SC_FY14  =  b.Soft,
	SJ_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	SEA_HC_FY14  =  b.Hard, 
	SEA_SC_FY14  =  b.Soft,
	SEA_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	TUL_HC_FY14  =  b.Hard, 
	TUL_SC_FY14  =  b.Soft,
	TUL_PandT_FY14	=  b.PandT
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY14 SET 
	WASH_HC_FY14  =  b.Hard, 
	WASH_SC_FY14  =  b.Soft,
	WASH_PandT_FY14	=  b.PandT 
	FROM ODW.Recent_History.DimRecentGivingFY14  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY14'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY13(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET
	BR_HC_FY13  = b.Hard,
	BR_SC_FY13  = b.Soft

	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET
	BOS_HC_FY13  = b.Hard,
	BOS_SC_FY13  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET
	CF_HC_FY13  = b.Hard,
	CF_SC_FY13  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	CHI_HC_FY13  =  b.Hard, 
	CHI_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	CLE_HC_FY13  =  b.Hard, 
	CLE_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	CIA_HC_FY13  =  b.Hard, 
	CIA_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	CUS_HC_FY13  =  b.Hard, 
	CUS_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Columbus'

	

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	DEN_HC_FY13  =  b.Hard, 
	DEN_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	DET_HC_FY13  =  b.Hard, 
	DET_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	HQ_HC_FY13  =  b.Hard, 
	HQ_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	JAX_HC_FY13  =  b.Hard, 
	JAX_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	LR_HC_FY13  =  b.Hard, 
	LR_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	LA_HC_FY13  =  b.Hard, 
	LA_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	LOU_HC_FY13  =  b.Hard, 
	LOU_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	MIA_HC_FY13  =  b.Hard, 
	MIA_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	MIL_HC_FY13  =  b.Hard, 
	MIL_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	NH_HC_FY13  =  b.Hard, 
	NH_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	NO_HC_FY13  =  b.Hard, 
	NO_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	NYC_HC_FY13  =  b.Hard, 
	NYC_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	ORL_HC_FY13  =  b.Hard, 
	ORL_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	PHI_HC_FY13  =  b.Hard, 
	PHI_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	RI_HC_FY13  =  b.Hard, 
	RI_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	SAC_HC_FY13  =  b.Hard, 
	SAC_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	SA_HC_FY13  =  b.Hard, 
	SA_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	SJ_HC_FY13  =  b.Hard, 
	SJ_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	SEA_HC_FY13  =  b.Hard, 
	SEA_SC_FY13  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	TUL_HC_FY13  =  b.Hard, 
	TUL_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY13 SET 
	WASH_HC_FY13  =  b.Hard, 
	WASH_SC_FY13  =  b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY13  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY13'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY12(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET
	BR_HC_FY12  = b.Hard,
	BR_SC_FY12  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET
	BOS_HC_FY12  = b.Hard,
	BOS_SC_FY12  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET
	CF_HC_FY12  = b.Hard,
	CF_SC_FY12  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	CHI_HC_FY12  =  b.Hard, 
	CHI_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	CLE_HC_FY12  =  b.Hard, 
	CLE_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	CIA_HC_FY12  =  b.Hard, 
	CIA_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	CUS_HC_FY12  =  b.Hard, 
	CUS_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Columbus'

	


	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	DEN_HC_FY12  =  b.Hard, 
	DEN_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	DET_HC_FY12  =  b.Hard, 
	DET_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	HQ_HC_FY12  =  b.Hard, 
	HQ_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	JAX_HC_FY12  =  b.Hard, 
	JAX_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	LR_HC_FY12  =  b.Hard, 
	LR_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	LA_HC_FY12  =  b.Hard, 
	LA_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	LOU_HC_FY12  =  b.Hard, 
	LOU_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	MIA_HC_FY12  =  b.Hard, 
	MIA_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	MIL_HC_FY12  =  b.Hard, 
	MIL_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	NH_HC_FY12  =  b.Hard, 
	NH_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	NO_HC_FY12  =  b.Hard, 
	NO_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	NYC_HC_FY12  =  b.Hard, 
	NYC_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	ORL_HC_FY12  =  b.Hard, 
	ORL_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	PHI_HC_FY12  =  b.Hard, 
	PHI_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	RI_HC_FY12  =  b.Hard, 
	RI_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	SAC_HC_FY12  =  b.Hard, 
	SAC_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	SA_HC_FY12  =  b.Hard, 
	SA_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	SJ_HC_FY12  =  b.Hard, 
	SJ_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	SEA_HC_FY12  =  b.Hard, 
	SEA_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	TUL_HC_FY12  =  b.Hard, 
	TUL_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY12 SET 
	WASH_HC_FY12  =  b.Hard, 
	WASH_SC_FY12  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY12  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY12'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY11(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET
	BR_HC_FY11  = b.Hard,
	BR_SC_FY11  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET
	BOS_HC_FY11  = b.Hard,
	BOS_SC_FY11  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET
	CF_HC_FY11  = b.Hard,
	CF_SC_FY11  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	CHI_HC_FY11  =  b.Hard, 
	CHI_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	CLE_HC_FY11  =  b.Hard, 
	CLE_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	CIA_HC_FY11  =  b.Hard, 
	CIA_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	CUS_HC_FY11  =  b.Hard, 
	CUS_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	DEN_HC_FY11  =  b.Hard, 
	DEN_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	DET_HC_FY11  =  b.Hard, 
	DET_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	HQ_HC_FY11  =  b.Hard, 
	HQ_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	JAX_HC_FY11  =  b.Hard, 
	JAX_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	LR_HC_FY11  =  b.Hard, 
	LR_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	LA_HC_FY11  =  b.Hard, 
	LA_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	LOU_HC_FY11  =  b.Hard, 
	LOU_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	MIA_HC_FY11  =  b.Hard, 
	MIA_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	MIL_HC_FY11  =  b.Hard, 
	MIL_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	NH_HC_FY11  =  b.Hard, 
	NH_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	NO_HC_FY11  =  b.Hard, 
	NO_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	NYC_HC_FY11  =  b.Hard, 
	NYC_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	ORL_HC_FY11  =  b.Hard, 
	ORL_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	PHI_HC_FY11  =  b.Hard, 
	PHI_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	RI_HC_FY11  =  b.Hard, 
	RI_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	SAC_HC_FY11  =  b.Hard, 
	SAC_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	SA_HC_FY11  =  b.Hard, 
	SA_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	SJ_HC_FY11  =  b.Hard, 
	SJ_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	SEA_HC_FY11  =  b.Hard, 
	SEA_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	TUL_HC_FY11  =  b.Hard, 
	TUL_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY11 SET 
	WASH_HC_FY11  =  b.Hard, 
	WASH_SC_FY11  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY11  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY11'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY10(AccountID)
	SELECT DISTINCT	AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET
	BR_HC_FY10  = b.Hard,
	BR_SC_FY10  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET
	BOS_HC_FY10  = b.Hard,
	BOS_SC_FY10  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET
	CF_HC_FY10  = b.Hard,
	CF_SC_FY10  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	CHI_HC_FY10  =  b.Hard, 
	CHI_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	CLE_HC_FY10  =  b.Hard, 
	CLE_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	CIA_HC_FY10  =  b.Hard, 
	CIA_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	CUS_HC_FY10  =  b.Hard, 
	CUS_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	DEN_HC_FY10  =  b.Hard, 
	DEN_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	DET_HC_FY10  =  b.Hard, 
	DET_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	HQ_HC_FY10  =  b.Hard, 
	HQ_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	JAX_HC_FY10  =  b.Hard, 
	JAX_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	LR_HC_FY10  =  b.Hard, 
	LR_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	LA_HC_FY10  =  b.Hard, 
	LA_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	LOU_HC_FY10  =  b.Hard, 
	LOU_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	MIA_HC_FY10  =  b.Hard, 
	MIA_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	MIL_HC_FY10  =  b.Hard, 
	MIL_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	NH_HC_FY10  =  b.Hard, 
	NH_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	NO_HC_FY10  =  b.Hard, 
	NO_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	NYC_HC_FY10  =  b.Hard, 
	NYC_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	ORL_HC_FY10  =  b.Hard, 
	ORL_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	PHI_HC_FY10  =  b.Hard, 
	PHI_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	RI_HC_FY10  =  b.Hard, 
	RI_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	SAC_HC_FY10  =  b.Hard, 
	SAC_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	SA_HC_FY10  =  b.Hard, 
	SA_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	SJ_HC_FY10  =  b.Hard, 
	SJ_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	SEA_HC_FY10  =  b.Hard, 
	SEA_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	TUL_HC_FY10  =  b.Hard, 
	TUL_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY10 SET 
	WASH_HC_FY10  =  b.Hard, 
	WASH_SC_FY10  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY10  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY10'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY09(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET
	BR_HC_FY09  = b.Hard,
	BR_SC_FY09  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET
	BOS_HC_FY09  = b.Hard,
	BOS_SC_FY09  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET
	CF_HC_FY09  = b.Hard,
	CF_SC_FY09  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	CHI_HC_FY09  =  b.Hard, 
	CHI_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	CLE_HC_FY09  =  b.Hard, 
	CLE_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	CIA_HC_FY09  =  b.Hard, 
	CIA_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	CUS_HC_FY09  =  b.Hard, 
	CUS_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	DEN_HC_FY09  =  b.Hard, 
	DEN_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	DET_HC_FY09  =  b.Hard, 
	DET_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	HQ_HC_FY09  =  b.Hard, 
	HQ_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	JAX_HC_FY09  =  b.Hard, 
	JAX_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	LR_HC_FY09  =  b.Hard, 
	LR_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	LA_HC_FY09  =  b.Hard, 
	LA_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	LOU_HC_FY09  =  b.Hard, 
	LOU_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	MIA_HC_FY09  =  b.Hard, 
	MIA_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	MIL_HC_FY09  =  b.Hard, 
	MIL_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	NH_HC_FY09  =  b.Hard, 
	NH_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	NO_HC_FY09  =  b.Hard, 
	NO_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	NYC_HC_FY09  =  b.Hard, 
	NYC_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	ORL_HC_FY09  =  b.Hard, 
	ORL_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	PHI_HC_FY09  =  b.Hard, 
	PHI_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	RI_HC_FY09  =  b.Hard, 
	RI_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	SAC_HC_FY09  =  b.Hard, 
	SAC_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	SA_HC_FY09  =  b.Hard, 
	SA_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	SJ_HC_FY09  =  b.Hard, 
	SJ_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	SEA_HC_FY09  =  b.Hard, 
	SEA_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	TUL_HC_FY09  =  b.Hard, 
	TUL_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY09 SET 
	WASH_HC_FY09  =  b.Hard, 
	WASH_SC_FY09  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY09  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY09'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY08(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET
	BR_HC_FY08  = b.Hard,
	BR_SC_FY08  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET
	BOS_HC_FY08  = b.Hard,
	BOS_SC_FY08  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET
	CF_HC_FY08  = b.Hard,
	CF_SC_FY08  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	CHI_HC_FY08  =  b.Hard, 
	CHI_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	CLE_HC_FY08  =  b.Hard, 
	CLE_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	CIA_HC_FY08  =  b.Hard, 
	CIA_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	CUS_HC_FY08  =  b.Hard, 
	CUS_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	DEN_HC_FY08  =  b.Hard, 
	DEN_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	DET_HC_FY08  =  b.Hard, 
	DET_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	HQ_HC_FY08  =  b.Hard, 
	HQ_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	JAX_HC_FY08  =  b.Hard, 
	JAX_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	LR_HC_FY08  =  b.Hard, 
	LR_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	LA_HC_FY08  =  b.Hard, 
	LA_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	LOU_HC_FY08  =  b.Hard, 
	LOU_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	MIA_HC_FY08  =  b.Hard, 
	MIA_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	MIL_HC_FY08  =  b.Hard, 
	MIL_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	NH_HC_FY08  =  b.Hard, 
	NH_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	NO_HC_FY08  =  b.Hard, 
	NO_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	NYC_HC_FY08  =  b.Hard, 
	NYC_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	ORL_HC_FY08  =  b.Hard, 
	ORL_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	PHI_HC_FY08  =  b.Hard, 
	PHI_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	RI_HC_FY08  =  b.Hard, 
	RI_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	SAC_HC_FY08  =  b.Hard, 
	SAC_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	SA_HC_FY08  =  b.Hard, 
	SA_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	SJ_HC_FY08  =  b.Hard, 
	SJ_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	SEA_HC_FY08  =  b.Hard, 
	SEA_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	TUL_HC_FY08  =  b.Hard, 
	TUL_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY08 SET 
	WASH_HC_FY08  =  b.Hard, 
	WASH_SC_FY08  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY08  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY08'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY07(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET
	BR_HC_FY07  = b.Hard,
	BR_SC_FY07  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET
	BOS_HC_FY07  = b.Hard,
	BOS_SC_FY07  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET
	CF_HC_FY07  = b.Hard,
	CF_SC_FY07  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	CHI_HC_FY07  =  b.Hard, 
	CHI_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	CLE_HC_FY07  =  b.Hard, 
	CLE_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	CIA_HC_FY07  =  b.Hard, 
	CIA_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	CUS_HC_FY07  =  b.Hard, 
	CUS_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	DEN_HC_FY07  =  b.Hard, 
	DEN_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	DET_HC_FY07  =  b.Hard, 
	DET_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	HQ_HC_FY07  =  b.Hard, 
	HQ_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	JAX_HC_FY07  =  b.Hard, 
	JAX_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	LR_HC_FY07  =  b.Hard, 
	LR_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	LA_HC_FY07  =  b.Hard, 
	LA_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	LOU_HC_FY07  =  b.Hard, 
	LOU_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	MIA_HC_FY07  =  b.Hard, 
	MIA_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	MIL_HC_FY07  =  b.Hard, 
	MIL_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	NH_HC_FY07  =  b.Hard, 
	NH_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	NO_HC_FY07  =  b.Hard, 
	NO_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	NYC_HC_FY07  =  b.Hard, 
	NYC_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	ORL_HC_FY07  =  b.Hard, 
	ORL_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	PHI_HC_FY07  =  b.Hard, 
	PHI_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	RI_HC_FY07  =  b.Hard, 
	RI_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	SAC_HC_FY07  =  b.Hard, 
	SAC_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	SA_HC_FY07  =  b.Hard, 
	SA_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	SJ_HC_FY07  =  b.Hard, 
	SJ_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	SEA_HC_FY07  =  b.Hard, 
	SEA_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	TUL_HC_FY07  =  b.Hard, 
	TUL_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY07 SET 
	WASH_HC_FY07  =  b.Hard, 
	WASH_SC_FY07  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY07  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY07'
	and b.site = 'Washington DC'


	INSERT INTO ODW.Recent_History.DimRecentGivingFY06(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET
	BR_HC_FY06  = b.Hard,
	BR_SC_FY06  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET
	BOS_HC_FY06  = b.Hard,
	BOS_SC_FY06  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET
	CF_HC_FY06  = b.Hard,
	CF_SC_FY06  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	CHI_HC_FY06  =  b.Hard, 
	CHI_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	CLE_HC_FY06  =  b.Hard, 
	CLE_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	CIA_HC_FY06  =  b.Hard, 
	CIA_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	CUS_HC_FY06  =  b.Hard, 
	CUS_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	DEN_HC_FY06  =  b.Hard, 
	DEN_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	DET_HC_FY06  =  b.Hard, 
	DET_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	HQ_HC_FY06  =  b.Hard, 
	HQ_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	JAX_HC_FY06  =  b.Hard, 
	JAX_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	LR_HC_FY06  =  b.Hard, 
	LR_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	LA_HC_FY06  =  b.Hard, 
	LA_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	LOU_HC_FY06  =  b.Hard, 
	LOU_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	MIA_HC_FY06  =  b.Hard, 
	MIA_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	MIL_HC_FY06  =  b.Hard, 
	MIL_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	NH_HC_FY06  =  b.Hard, 
	NH_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	NO_HC_FY06  =  b.Hard, 
	NO_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	NYC_HC_FY06  =  b.Hard, 
	NYC_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	ORL_HC_FY06  =  b.Hard, 
	ORL_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	PHI_HC_FY06  =  b.Hard, 
	PHI_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	RI_HC_FY06  =  b.Hard, 
	RI_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	SAC_HC_FY06  =  b.Hard, 
	SAC_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	SA_HC_FY06  =  b.Hard, 
	SA_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	SJ_HC_FY06  =  b.Hard, 
	SJ_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	SEA_HC_FY06  =  b.Hard, 
	SEA_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	TUL_HC_FY06  =  b.Hard, 
	TUL_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY06 SET 
	WASH_HC_FY06  =  b.Hard, 
	WASH_SC_FY06  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY06  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY06'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimRecentGivingFY05(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

	-- STEP TWO UPDATE FIELDS PER SITE--------------------------------------------------------------------------------

	--BATON ROUGE
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET
	BR_HC_FY05  = b.Hard,
	BR_SC_FY05  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	AND b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET
	BOS_HC_FY05  = b.Hard,
	BOS_SC_FY05  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	AND b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET
	CF_HC_FY05  = b.Hard,
	CF_SC_FY05  = b.Soft
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	AND b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	CHI_HC_FY05  =  b.Hard, 
	CHI_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05' 
	and b.site = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	CLE_HC_FY05  =  b.Hard, 
	CLE_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	CIA_HC_FY05  =  b.Hard, 
	CIA_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	CUS_HC_FY05  =  b.Hard, 
	CUS_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Columbus'

	--Denver
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	DEN_HC_FY05  =  b.Hard, 
	DEN_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	DET_HC_FY05  =  b.Hard, 
	DET_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	HQ_HC_FY05  =  b.Hard, 
	HQ_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	JAX_HC_FY05  =  b.Hard, 
	JAX_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	LR_HC_FY05  =  b.Hard, 
	LR_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	LA_HC_FY05  =  b.Hard, 
	LA_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	LOU_HC_FY05  =  b.Hard, 
	LOU_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	MIA_HC_FY05  =  b.Hard, 
	MIA_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	MIL_HC_FY05  =  b.Hard, 
	MIL_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	NH_HC_FY05  =  b.Hard, 
	NH_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	NO_HC_FY05  =  b.Hard, 
	NO_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	NYC_HC_FY05  =  b.Hard, 
	NYC_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	ORL_HC_FY05  =  b.Hard, 
	ORL_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	PHI_HC_FY05  =  b.Hard, 
	PHI_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	RI_HC_FY05  =  b.Hard, 
	RI_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	SAC_HC_FY05  =  b.Hard, 
	SAC_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	SA_HC_FY05  =  b.Hard, 
	SA_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	SJ_HC_FY05  =  b.Hard, 
	SJ_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	SEA_HC_FY05  =  b.Hard, 
	SEA_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	TUL_HC_FY05  =  b.Hard, 
	TUL_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimRecentGivingFY05 SET 
	WASH_HC_FY05  =  b.Hard, 
	WASH_SC_FY05  =  b.Soft 
	FROM ODW.Recent_History.DimRecentGivingFY05  a inner join DimAccountGivingHistory b on a.accountid = b.accountid
	where b.year = 'FY05'
	and b.site = 'Washington DC'

	INSERT INTO ODW.Recent_History.DimTotalGiving(AccountID)
	SELECT DISTINCT AccountID FROM [DimAccountGivingHistory]

		--BATON ROUGE
	UPDATE ODW.Recent_History.DimTotalGiving SET
	BR_HC_Total  = b.Hard,
	BR_SC_Total  = b.Soft
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Baton Rouge'


	--BOSTON
	UPDATE ODW.Recent_History.DimTotalGiving SET
	BOS_HC_Total  = b.Hard,
	BOS_SC_Total  = b.Soft
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Boston'
 

	--CareForce
	UPDATE ODW.Recent_History.DimTotalGiving SET
	CF_HC_Total  = b.Hard,
	CF_SC_Total  = b.Soft
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'CareForce'

	--Chicago

	UPDATE ODW.Recent_History.DimTotalGiving SET 
	CHI_HC_Total  =  b.Hard, 
	CHI_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Chicago'


	--Cleveland
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	CLE_HC_Total  =  b.Hard, 
	CLE_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Cleveland'


	--Columbia
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	CIA_HC_Total  =  b.Hard, 
	CIA_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Columbia'


	--Columbus
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	CUS_HC_Total  =  b.Hard, 
	CUS_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Columbus'

	--Dallas
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	DAL_HC_Total  =  b.Hard, 
	DAL_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Dallas'

	--Denver
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	DEN_HC_Total  =  b.Hard, 
	DEN_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Denver'

	--Detroit
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	DET_HC_Total  =  b.Hard, 
	DET_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Detroit'

	--Headquarters
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	HQ_HC_Total  =  b.Hard, 
	HQ_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Headquarters'

	--Jacksonville
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	JAX_HC_Total  =  b.Hard, 
	JAX_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Jacksonville'

	--Little Rock
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	LR_HC_Total  =  b.Hard, 
	LR_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Little Rock'

	--Los Angeles
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	LA_HC_Total  =  b.Hard, 
	LA_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Los Angeles'

	--Louisiana
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	LOU_HC_Total  =  b.Hard, 
	LOU_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Louisiana'

	--Miami
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	MIA_HC_Total  =  b.Hard, 
	MIA_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Miami'

	--Milwaukee
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	MIL_HC_Total  =  b.Hard, 
	MIL_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Milwaukee'


	--New Hampshire
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	NH_HC_Total  =  b.Hard, 
	NH_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'New Hampshire'

	--New Orleans
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	NO_HC_Total  =  b.Hard, 
	NO_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'New Orleans'


	-- New York City
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	NYC_HC_Total  =  b.Hard, 
	NYC_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'New York City'
 
	--Orlando
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	ORL_HC_Total  =  b.Hard, 
	ORL_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Orlando'

	--Philadelphia
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	PHI_HC_Total  =  b.Hard, 
	PHI_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Philadelphia'

	--Rhode Island
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	RI_HC_Total  =  b.Hard, 
	RI_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Rhode Island'

	--Sacramento
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	SAC_HC_Total  =  b.Hard, 
	SAC_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Sacramento'

	--San Antonio
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	SA_HC_Total  =  b.Hard, 
	SA_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'San Antonio'


	--San Jose
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	SJ_HC_Total  =  b.Hard, 
	SJ_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'San Jose'


	--Seattle
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	SEA_HC_Total  =  b.Hard, 
	SEA_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Seattle'

	--Tulsa
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	TUL_HC_Total  =  b.Hard, 
	TUL_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Tulsa'

	--Washington DC
	UPDATE ODW.Recent_History.DimTotalGiving SET 
	WASH_HC_Total  =  b.Hard, 
	WASH_SC_Total  =  b.Soft 
	FROM ODW.Recent_History.DimTotalGiving  a inner join (select AccountID, Site, sum(Hard) Hard, sum(Soft) Soft from DimAccountGivingHistory where Year not in ('FY16','FY17','FY18','FY19','FY20','FY21','FY22') group by AccountID, Site) b on a.accountid = b.accountid
	WHERE b.SITE = 'Washington DC'



	update ODW.Recent_History.DimRecentGivingFY05 set BR_HC_FY05 = 0  where BR_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set BR_SC_FY05 = 0  where BR_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set BOS_HC_FY05 = 0  where BOS_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set BOS_SC_FY05 = 0  where BOS_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CF_HC_FY05 = 0  where CF_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CF_SC_FY05 = 0  where CF_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CHI_HC_FY05 = 0  where CHI_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CHI_SC_FY05 = 0  where CHI_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CLE_HC_FY05 = 0  where CLE_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CLE_SC_FY05 = 0  where CLE_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CIA_HC_FY05 = 0  where CIA_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CIA_SC_FY05 = 0  where CIA_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CUS_HC_FY05 = 0  where CUS_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set CUS_SC_FY05 = 0  where CUS_SC_FY05 is null
	

	update ODW.Recent_History.DimRecentGivingFY05 set DEN_HC_FY05 = 0  where DEN_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set DEN_SC_FY05 = 0  where DEN_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set DET_HC_FY05 = 0  where DET_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set DET_SC_FY05 = 0  where DET_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set HQ_HC_FY05 = 0  where HQ_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set HQ_SC_FY05 = 0  where HQ_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set JAX_HC_FY05 = 0  where JAX_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set JAX_SC_FY05 = 0  where JAX_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LR_HC_FY05 = 0  where LR_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LR_SC_FY05 = 0  where LR_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LA_HC_FY05 = 0  where LA_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LA_SC_FY05 = 0  where LA_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LOU_HC_FY05 = 0  where LOU_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set LOU_SC_FY05 = 0  where LOU_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set MIA_HC_FY05 = 0  where MIA_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set MIA_SC_FY05 = 0  where MIA_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set MIL_HC_FY05 = 0  where MIL_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set MIL_SC_FY05 = 0  where MIL_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NH_HC_FY05 = 0  where NH_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NH_SC_FY05 = 0  where NH_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NO_HC_FY05 = 0  where NO_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NO_SC_FY05 = 0  where NO_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NYC_HC_FY05 = 0  where NYC_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set NYC_SC_FY05 = 0  where NYC_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set ORL_HC_FY05 = 0  where ORL_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set ORL_SC_FY05 = 0  where ORL_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set PHI_HC_FY05 = 0  where PHI_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set PHI_SC_FY05 = 0  where PHI_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set RI_HC_FY05 = 0  where RI_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set RI_SC_FY05 = 0  where RI_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SAC_HC_FY05 = 0  where SAC_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SAC_SC_FY05 = 0  where SAC_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SA_HC_FY05 = 0  where SA_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SA_SC_FY05 = 0  where SA_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SJ_HC_FY05 = 0  where SJ_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SJ_SC_FY05 = 0  where SJ_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SEA_HC_FY05 = 0  where SEA_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set SEA_SC_FY05 = 0  where SEA_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set TUL_HC_FY05 = 0  where TUL_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set TUL_SC_FY05 = 0  where TUL_SC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set WASH_HC_FY05 = 0  where WASH_HC_FY05 is null
	update ODW.Recent_History.DimRecentGivingFY05 set WASH_SC_FY05 = 0  where WASH_SC_FY05 is null


	update ODW.Recent_History.DimRecentGivingFY06 set BR_HC_FY06 = 0  where BR_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set BR_SC_FY06 = 0  where BR_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set BOS_HC_FY06 = 0  where BOS_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set BOS_SC_FY06 = 0  where BOS_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CF_HC_FY06 = 0  where CF_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CF_SC_FY06 = 0  where CF_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CHI_HC_FY06 = 0  where CHI_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CHI_SC_FY06 = 0  where CHI_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CLE_HC_FY06 = 0  where CLE_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CLE_SC_FY06 = 0  where CLE_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CIA_HC_FY06 = 0  where CIA_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CIA_SC_FY06 = 0  where CIA_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CUS_HC_FY06 = 0  where CUS_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set CUS_SC_FY06 = 0  where CUS_SC_FY06 is null

	

	update ODW.Recent_History.DimRecentGivingFY06 set DEN_HC_FY06 = 0  where DEN_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set DEN_SC_FY06 = 0  where DEN_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set DET_HC_FY06 = 0  where DET_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set DET_SC_FY06 = 0  where DET_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set HQ_HC_FY06 = 0  where HQ_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set HQ_SC_FY06 = 0  where HQ_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set JAX_HC_FY06 = 0  where JAX_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set JAX_SC_FY06 = 0  where JAX_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LR_HC_FY06 = 0  where LR_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LR_SC_FY06 = 0  where LR_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LA_HC_FY06 = 0  where LA_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LA_SC_FY06 = 0  where LA_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LOU_HC_FY06 = 0  where LOU_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set LOU_SC_FY06 = 0  where LOU_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set MIA_HC_FY06 = 0  where MIA_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set MIA_SC_FY06 = 0  where MIA_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set MIL_HC_FY06 = 0  where MIL_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set MIL_SC_FY06 = 0  where MIL_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NH_HC_FY06 = 0  where NH_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NH_SC_FY06 = 0  where NH_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NO_HC_FY06 = 0  where NO_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NO_SC_FY06 = 0  where NO_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NYC_HC_FY06 = 0  where NYC_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set NYC_SC_FY06 = 0  where NYC_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set ORL_HC_FY06 = 0  where ORL_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set ORL_SC_FY06 = 0  where ORL_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set PHI_HC_FY06 = 0  where PHI_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set PHI_SC_FY06 = 0  where PHI_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set RI_HC_FY06 = 0  where RI_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set RI_SC_FY06 = 0  where RI_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SAC_HC_FY06 = 0  where SAC_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SAC_SC_FY06 = 0  where SAC_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SA_HC_FY06 = 0  where SA_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SA_SC_FY06 = 0  where SA_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SJ_HC_FY06 = 0  where SJ_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SJ_SC_FY06 = 0  where SJ_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SEA_HC_FY06 = 0  where SEA_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set SEA_SC_FY06 = 0  where SEA_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set TUL_HC_FY06 = 0  where TUL_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set TUL_SC_FY06 = 0  where TUL_SC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set WASH_HC_FY06 = 0  where WASH_HC_FY06 is null
	update ODW.Recent_History.DimRecentGivingFY06 set WASH_SC_FY06 = 0  where WASH_SC_FY06 is null



	update ODW.Recent_History.DimRecentGivingFY07 set BR_HC_FY07 = 0  where BR_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set BR_SC_FY07 = 0  where BR_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set BOS_HC_FY07 = 0  where BOS_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set BOS_SC_FY07 = 0  where BOS_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CF_HC_FY07 = 0  where CF_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CF_SC_FY07 = 0  where CF_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CHI_HC_FY07 = 0  where CHI_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CHI_SC_FY07 = 0  where CHI_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CLE_HC_FY07 = 0  where CLE_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CLE_SC_FY07 = 0  where CLE_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CIA_HC_FY07 = 0  where CIA_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CIA_SC_FY07 = 0  where CIA_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CUS_HC_FY07 = 0  where CUS_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set CUS_SC_FY07 = 0  where CUS_SC_FY07 is null

	

	update ODW.Recent_History.DimRecentGivingFY07 set DEN_HC_FY07 = 0  where DEN_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set DEN_SC_FY07 = 0  where DEN_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set DET_HC_FY07 = 0  where DET_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set DET_SC_FY07 = 0  where DET_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set HQ_HC_FY07 = 0  where HQ_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set HQ_SC_FY07 = 0  where HQ_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set JAX_HC_FY07 = 0  where JAX_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set JAX_SC_FY07 = 0  where JAX_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LR_HC_FY07 = 0  where LR_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LR_SC_FY07 = 0  where LR_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LA_HC_FY07 = 0  where LA_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LA_SC_FY07 = 0  where LA_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LOU_HC_FY07 = 0  where LOU_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set LOU_SC_FY07 = 0  where LOU_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set MIA_HC_FY07 = 0  where MIA_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set MIA_SC_FY07 = 0  where MIA_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set MIL_HC_FY07 = 0  where MIL_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set MIL_SC_FY07 = 0  where MIL_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NH_HC_FY07 = 0  where NH_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NH_SC_FY07 = 0  where NH_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NO_HC_FY07 = 0  where NO_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NO_SC_FY07 = 0  where NO_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NYC_HC_FY07 = 0  where NYC_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set NYC_SC_FY07 = 0  where NYC_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set ORL_HC_FY07 = 0  where ORL_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set ORL_SC_FY07 = 0  where ORL_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set PHI_HC_FY07 = 0  where PHI_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set PHI_SC_FY07 = 0  where PHI_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set RI_HC_FY07 = 0  where RI_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set RI_SC_FY07 = 0  where RI_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SAC_HC_FY07 = 0  where SAC_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SAC_SC_FY07 = 0  where SAC_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SA_HC_FY07 = 0  where SA_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SA_SC_FY07 = 0  where SA_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SJ_HC_FY07 = 0  where SJ_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SJ_SC_FY07 = 0  where SJ_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SEA_HC_FY07 = 0  where SEA_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set SEA_SC_FY07 = 0  where SEA_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set TUL_HC_FY07 = 0  where TUL_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set TUL_SC_FY07 = 0  where TUL_SC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set WASH_HC_FY07 = 0  where WASH_HC_FY07 is null
	update ODW.Recent_History.DimRecentGivingFY07 set WASH_SC_FY07 = 0  where WASH_SC_FY07 is null


	update ODW.Recent_History.DimRecentGivingFY08 set BR_HC_FY08 = 0  where BR_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set BR_SC_FY08 = 0  where BR_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set BOS_HC_FY08 = 0  where BOS_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set BOS_SC_FY08 = 0  where BOS_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CF_HC_FY08 = 0  where CF_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CF_SC_FY08 = 0  where CF_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CHI_HC_FY08 = 0  where CHI_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CHI_SC_FY08 = 0  where CHI_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CLE_HC_FY08 = 0  where CLE_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CLE_SC_FY08 = 0  where CLE_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CIA_HC_FY08 = 0  where CIA_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CIA_SC_FY08 = 0  where CIA_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CUS_HC_FY08 = 0  where CUS_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set CUS_SC_FY08 = 0  where CUS_SC_FY08 is null

	

	update ODW.Recent_History.DimRecentGivingFY08 set DEN_HC_FY08 = 0  where DEN_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set DEN_SC_FY08 = 0  where DEN_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set DET_HC_FY08 = 0  where DET_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set DET_SC_FY08 = 0  where DET_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set HQ_HC_FY08 = 0  where HQ_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set HQ_SC_FY08 = 0  where HQ_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set JAX_HC_FY08 = 0  where JAX_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set JAX_SC_FY08 = 0  where JAX_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LR_HC_FY08 = 0  where LR_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LR_SC_FY08 = 0  where LR_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LA_HC_FY08 = 0  where LA_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LA_SC_FY08 = 0  where LA_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LOU_HC_FY08 = 0  where LOU_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set LOU_SC_FY08 = 0  where LOU_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set MIA_HC_FY08 = 0  where MIA_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set MIA_SC_FY08 = 0  where MIA_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set MIL_HC_FY08 = 0  where MIL_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set MIL_SC_FY08 = 0  where MIL_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NH_HC_FY08 = 0  where NH_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NH_SC_FY08 = 0  where NH_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NO_HC_FY08 = 0  where NO_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NO_SC_FY08 = 0  where NO_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NYC_HC_FY08 = 0  where NYC_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set NYC_SC_FY08 = 0  where NYC_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set ORL_HC_FY08 = 0  where ORL_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set ORL_SC_FY08 = 0  where ORL_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set PHI_HC_FY08 = 0  where PHI_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set PHI_SC_FY08 = 0  where PHI_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set RI_HC_FY08 = 0  where RI_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set RI_SC_FY08 = 0  where RI_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SAC_HC_FY08 = 0  where SAC_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SAC_SC_FY08 = 0  where SAC_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SA_HC_FY08 = 0  where SA_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SA_SC_FY08 = 0  where SA_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SJ_HC_FY08 = 0  where SJ_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SJ_SC_FY08 = 0  where SJ_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SEA_HC_FY08 = 0  where SEA_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set SEA_SC_FY08 = 0  where SEA_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set TUL_HC_FY08 = 0  where TUL_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set TUL_SC_FY08 = 0  where TUL_SC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set WASH_HC_FY08 = 0  where WASH_HC_FY08 is null
	update ODW.Recent_History.DimRecentGivingFY08 set WASH_SC_FY08 = 0  where WASH_SC_FY08 is null



	update ODW.Recent_History.DimRecentGivingFY09 set BR_HC_FY09 = 0  where BR_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set BR_SC_FY09 = 0  where BR_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set BOS_HC_FY09 = 0  where BOS_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set BOS_SC_FY09 = 0  where BOS_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CF_HC_FY09 = 0  where CF_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CF_SC_FY09 = 0  where CF_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CHI_HC_FY09 = 0  where CHI_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CHI_SC_FY09 = 0  where CHI_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CLE_HC_FY09 = 0  where CLE_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CLE_SC_FY09 = 0  where CLE_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CIA_HC_FY09 = 0  where CIA_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CIA_SC_FY09 = 0  where CIA_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CUS_HC_FY09 = 0  where CUS_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set CUS_SC_FY09 = 0  where CUS_SC_FY09 is null

	

	update ODW.Recent_History.DimRecentGivingFY09 set DEN_HC_FY09 = 0  where DEN_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set DEN_SC_FY09 = 0  where DEN_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set DET_HC_FY09 = 0  where DET_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set DET_SC_FY09 = 0  where DET_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set HQ_HC_FY09 = 0  where HQ_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set HQ_SC_FY09 = 0  where HQ_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set JAX_HC_FY09 = 0  where JAX_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set JAX_SC_FY09 = 0  where JAX_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LR_HC_FY09 = 0  where LR_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LR_SC_FY09 = 0  where LR_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LA_HC_FY09 = 0  where LA_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LA_SC_FY09 = 0  where LA_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LOU_HC_FY09 = 0  where LOU_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set LOU_SC_FY09 = 0  where LOU_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set MIA_HC_FY09 = 0  where MIA_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set MIA_SC_FY09 = 0  where MIA_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set MIL_HC_FY09 = 0  where MIL_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set MIL_SC_FY09 = 0  where MIL_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NH_HC_FY09 = 0  where NH_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NH_SC_FY09 = 0  where NH_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NO_HC_FY09 = 0  where NO_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NO_SC_FY09 = 0  where NO_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NYC_HC_FY09 = 0  where NYC_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set NYC_SC_FY09 = 0  where NYC_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set ORL_HC_FY09 = 0  where ORL_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set ORL_SC_FY09 = 0  where ORL_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set PHI_HC_FY09 = 0  where PHI_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set PHI_SC_FY09 = 0  where PHI_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set RI_HC_FY09 = 0  where RI_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set RI_SC_FY09 = 0  where RI_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SAC_HC_FY09 = 0  where SAC_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SAC_SC_FY09 = 0  where SAC_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SA_HC_FY09 = 0  where SA_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SA_SC_FY09 = 0  where SA_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SJ_HC_FY09 = 0  where SJ_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SJ_SC_FY09 = 0  where SJ_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SEA_HC_FY09 = 0  where SEA_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set SEA_SC_FY09 = 0  where SEA_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set TUL_HC_FY09 = 0  where TUL_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set TUL_SC_FY09 = 0  where TUL_SC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set WASH_HC_FY09 = 0  where WASH_HC_FY09 is null
	update ODW.Recent_History.DimRecentGivingFY09 set WASH_SC_FY09 = 0  where WASH_SC_FY09 is null


	update ODW.Recent_History.DimRecentGivingFY10 set BR_HC_FY10 = 0  where BR_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set BR_SC_FY10 = 0  where BR_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set BOS_HC_FY10 = 0  where BOS_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set BOS_SC_FY10 = 0  where BOS_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CF_HC_FY10 = 0  where CF_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CF_SC_FY10 = 0  where CF_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CHI_HC_FY10 = 0  where CHI_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CHI_SC_FY10 = 0  where CHI_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CLE_HC_FY10 = 0  where CLE_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CLE_SC_FY10 = 0  where CLE_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CIA_HC_FY10 = 0  where CIA_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CIA_SC_FY10 = 0  where CIA_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CUS_HC_FY10 = 0  where CUS_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set CUS_SC_FY10 = 0  where CUS_SC_FY10 is null


	update ODW.Recent_History.DimRecentGivingFY10 set DEN_HC_FY10 = 0  where DEN_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set DEN_SC_FY10 = 0  where DEN_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set DET_HC_FY10 = 0  where DET_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set DET_SC_FY10 = 0  where DET_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set HQ_HC_FY10 = 0  where HQ_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set HQ_SC_FY10 = 0  where HQ_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set JAX_HC_FY10 = 0  where JAX_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set JAX_SC_FY10 = 0  where JAX_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LR_HC_FY10 = 0  where LR_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LR_SC_FY10 = 0  where LR_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LA_HC_FY10 = 0  where LA_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LA_SC_FY10 = 0  where LA_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LOU_HC_FY10 = 0  where LOU_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set LOU_SC_FY10 = 0  where LOU_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set MIA_HC_FY10 = 0  where MIA_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set MIA_SC_FY10 = 0  where MIA_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set MIL_HC_FY10 = 0  where MIL_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set MIL_SC_FY10 = 0  where MIL_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NH_HC_FY10 = 0  where NH_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NH_SC_FY10 = 0  where NH_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NO_HC_FY10 = 0  where NO_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NO_SC_FY10 = 0  where NO_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NYC_HC_FY10 = 0  where NYC_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set NYC_SC_FY10 = 0  where NYC_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set ORL_HC_FY10 = 0  where ORL_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set ORL_SC_FY10 = 0  where ORL_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set PHI_HC_FY10 = 0  where PHI_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set PHI_SC_FY10 = 0  where PHI_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set RI_HC_FY10 = 0  where RI_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set RI_SC_FY10 = 0  where RI_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SAC_HC_FY10 = 0  where SAC_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SAC_SC_FY10 = 0  where SAC_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SA_HC_FY10 = 0  where SA_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SA_SC_FY10 = 0  where SA_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SJ_HC_FY10 = 0  where SJ_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SJ_SC_FY10 = 0  where SJ_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SEA_HC_FY10 = 0  where SEA_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set SEA_SC_FY10 = 0  where SEA_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set TUL_HC_FY10 = 0  where TUL_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set TUL_SC_FY10 = 0  where TUL_SC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set WASH_HC_FY10 = 0  where WASH_HC_FY10 is null
	update ODW.Recent_History.DimRecentGivingFY10 set WASH_SC_FY10 = 0  where WASH_SC_FY10 is null



	update ODW.Recent_History.DimRecentGivingFY11 set BR_HC_FY11 = 0  where BR_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set BR_SC_FY11 = 0  where BR_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set BOS_HC_FY11 = 0  where BOS_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set BOS_SC_FY11 = 0  where BOS_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CF_HC_FY11 = 0  where CF_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CF_SC_FY11 = 0  where CF_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CHI_HC_FY11 = 0  where CHI_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CHI_SC_FY11 = 0  where CHI_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CLE_HC_FY11 = 0  where CLE_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CLE_SC_FY11 = 0  where CLE_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CIA_HC_FY11 = 0  where CIA_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CIA_SC_FY11 = 0  where CIA_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CUS_HC_FY11 = 0  where CUS_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set CUS_SC_FY11 = 0  where CUS_SC_FY11 is null


	update ODW.Recent_History.DimRecentGivingFY11 set DEN_HC_FY11 = 0  where DEN_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set DEN_SC_FY11 = 0  where DEN_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set DET_HC_FY11 = 0  where DET_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set DET_SC_FY11 = 0  where DET_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set HQ_HC_FY11 = 0  where HQ_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set HQ_SC_FY11 = 0  where HQ_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set JAX_HC_FY11 = 0  where JAX_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set JAX_SC_FY11 = 0  where JAX_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LR_HC_FY11 = 0  where LR_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LR_SC_FY11 = 0  where LR_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LA_HC_FY11 = 0  where LA_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LA_SC_FY11 = 0  where LA_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LOU_HC_FY11 = 0  where LOU_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set LOU_SC_FY11 = 0  where LOU_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set MIA_HC_FY11 = 0  where MIA_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set MIA_SC_FY11 = 0  where MIA_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set MIL_HC_FY11 = 0  where MIL_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set MIL_SC_FY11 = 0  where MIL_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NH_HC_FY11 = 0  where NH_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NH_SC_FY11 = 0  where NH_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NO_HC_FY11 = 0  where NO_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NO_SC_FY11 = 0  where NO_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NYC_HC_FY11 = 0  where NYC_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set NYC_SC_FY11 = 0  where NYC_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set ORL_HC_FY11 = 0  where ORL_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set ORL_SC_FY11 = 0  where ORL_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set PHI_HC_FY11 = 0  where PHI_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set PHI_SC_FY11 = 0  where PHI_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set RI_HC_FY11 = 0  where RI_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set RI_SC_FY11 = 0  where RI_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SAC_HC_FY11 = 0  where SAC_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SAC_SC_FY11 = 0  where SAC_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SA_HC_FY11 = 0  where SA_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SA_SC_FY11 = 0  where SA_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SJ_HC_FY11 = 0  where SJ_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SJ_SC_FY11 = 0  where SJ_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SEA_HC_FY11 = 0  where SEA_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set SEA_SC_FY11 = 0  where SEA_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set TUL_HC_FY11 = 0  where TUL_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set TUL_SC_FY11 = 0  where TUL_SC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set WASH_HC_FY11 = 0  where WASH_HC_FY11 is null
	update ODW.Recent_History.DimRecentGivingFY11 set WASH_SC_FY11 = 0  where WASH_SC_FY11 is null



	update ODW.Recent_History.DimRecentGivingFY12 set BR_HC_FY12 = 0  where BR_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set BR_SC_FY12 = 0  where BR_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set BOS_HC_FY12 = 0  where BOS_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set BOS_SC_FY12 = 0  where BOS_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CF_HC_FY12 = 0  where CF_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CF_SC_FY12 = 0  where CF_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CHI_HC_FY12 = 0  where CHI_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CHI_SC_FY12 = 0  where CHI_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CLE_HC_FY12 = 0  where CLE_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CLE_SC_FY12 = 0  where CLE_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CIA_HC_FY12 = 0  where CIA_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CIA_SC_FY12 = 0  where CIA_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CUS_HC_FY12 = 0  where CUS_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set CUS_SC_FY12 = 0  where CUS_SC_FY12 is null


	update ODW.Recent_History.DimRecentGivingFY12 set DEN_HC_FY12 = 0  where DEN_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set DEN_SC_FY12 = 0  where DEN_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set DET_HC_FY12 = 0  where DET_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set DET_SC_FY12 = 0  where DET_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set HQ_HC_FY12 = 0  where HQ_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set HQ_SC_FY12 = 0  where HQ_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set JAX_HC_FY12 = 0  where JAX_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set JAX_SC_FY12 = 0  where JAX_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LR_HC_FY12 = 0  where LR_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LR_SC_FY12 = 0  where LR_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LA_HC_FY12 = 0  where LA_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LA_SC_FY12 = 0  where LA_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LOU_HC_FY12 = 0  where LOU_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set LOU_SC_FY12 = 0  where LOU_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set MIA_HC_FY12 = 0  where MIA_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set MIA_SC_FY12 = 0  where MIA_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set MIL_HC_FY12 = 0  where MIL_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set MIL_SC_FY12 = 0  where MIL_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NH_HC_FY12 = 0  where NH_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NH_SC_FY12 = 0  where NH_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NO_HC_FY12 = 0  where NO_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NO_SC_FY12 = 0  where NO_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NYC_HC_FY12 = 0  where NYC_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set NYC_SC_FY12 = 0  where NYC_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set ORL_HC_FY12 = 0  where ORL_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set ORL_SC_FY12 = 0  where ORL_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set PHI_HC_FY12 = 0  where PHI_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set PHI_SC_FY12 = 0  where PHI_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set RI_HC_FY12 = 0  where RI_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set RI_SC_FY12 = 0  where RI_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SAC_HC_FY12 = 0  where SAC_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SAC_SC_FY12 = 0  where SAC_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SA_HC_FY12 = 0  where SA_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SA_SC_FY12 = 0  where SA_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SJ_HC_FY12 = 0  where SJ_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SJ_SC_FY12 = 0  where SJ_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SEA_HC_FY12 = 0  where SEA_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set SEA_SC_FY12 = 0  where SEA_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set TUL_HC_FY12 = 0  where TUL_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set TUL_SC_FY12 = 0  where TUL_SC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set WASH_HC_FY12 = 0  where WASH_HC_FY12 is null
	update ODW.Recent_History.DimRecentGivingFY12 set WASH_SC_FY12 = 0  where WASH_SC_FY12 is null



	update ODW.Recent_History.DimRecentGivingFY13 set BR_HC_FY13 = 0  where BR_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set BR_SC_FY13 = 0  where BR_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set BOS_HC_FY13 = 0  where BOS_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set BOS_SC_FY13 = 0  where BOS_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CF_HC_FY13 = 0  where CF_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CF_SC_FY13 = 0  where CF_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CHI_HC_FY13 = 0  where CHI_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CHI_SC_FY13 = 0  where CHI_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CLE_HC_FY13 = 0  where CLE_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CLE_SC_FY13 = 0  where CLE_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CIA_HC_FY13 = 0  where CIA_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CIA_SC_FY13 = 0  where CIA_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CUS_HC_FY13 = 0  where CUS_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set CUS_SC_FY13 = 0  where CUS_SC_FY13 is null


	update ODW.Recent_History.DimRecentGivingFY13 set DEN_HC_FY13 = 0  where DEN_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set DEN_SC_FY13 = 0  where DEN_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set DET_HC_FY13 = 0  where DET_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set DET_SC_FY13 = 0  where DET_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set HQ_HC_FY13 = 0  where HQ_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set HQ_SC_FY13 = 0  where HQ_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set JAX_HC_FY13 = 0  where JAX_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set JAX_SC_FY13 = 0  where JAX_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LR_HC_FY13 = 0  where LR_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LR_SC_FY13 = 0  where LR_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LA_HC_FY13 = 0  where LA_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LA_SC_FY13 = 0  where LA_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LOU_HC_FY13 = 0  where LOU_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set LOU_SC_FY13 = 0  where LOU_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set MIA_HC_FY13 = 0  where MIA_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set MIA_SC_FY13 = 0  where MIA_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set MIL_HC_FY13 = 0  where MIL_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set MIL_SC_FY13 = 0  where MIL_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NH_HC_FY13 = 0  where NH_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NH_SC_FY13 = 0  where NH_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NO_HC_FY13 = 0  where NO_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NO_SC_FY13 = 0  where NO_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NYC_HC_FY13 = 0  where NYC_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set NYC_SC_FY13 = 0  where NYC_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set ORL_HC_FY13 = 0  where ORL_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set ORL_SC_FY13 = 0  where ORL_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set PHI_HC_FY13 = 0  where PHI_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set PHI_SC_FY13 = 0  where PHI_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set RI_HC_FY13 = 0  where RI_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set RI_SC_FY13 = 0  where RI_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SAC_HC_FY13 = 0  where SAC_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SAC_SC_FY13 = 0  where SAC_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SA_HC_FY13 = 0  where SA_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SA_SC_FY13 = 0  where SA_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SJ_HC_FY13 = 0  where SJ_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SJ_SC_FY13 = 0  where SJ_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SEA_HC_FY13 = 0  where SEA_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set SEA_SC_FY13 = 0  where SEA_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set TUL_HC_FY13 = 0  where TUL_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set TUL_SC_FY13 = 0  where TUL_SC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set WASH_HC_FY13 = 0  where WASH_HC_FY13 is null
	update ODW.Recent_History.DimRecentGivingFY13 set WASH_SC_FY13 = 0  where WASH_SC_FY13 is null



	update ODW.Recent_History.DimRecentGivingFY14 set BR_HC_FY14 = 0  where BR_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set BR_SC_FY14 = 0  where BR_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set BOS_HC_FY14 = 0  where BOS_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set BOS_SC_FY14 = 0  where BOS_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CF_HC_FY14 = 0  where CF_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CF_SC_FY14 = 0  where CF_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CHI_HC_FY14 = 0  where CHI_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CHI_SC_FY14 = 0  where CHI_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CLE_HC_FY14 = 0  where CLE_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CLE_SC_FY14 = 0  where CLE_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CIA_HC_FY14 = 0  where CIA_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CIA_SC_FY14 = 0  where CIA_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CUS_HC_FY14 = 0  where CUS_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CUS_SC_FY14 = 0  where CUS_SC_FY14 is null



	update ODW.Recent_History.DimRecentGivingFY14 set DEN_HC_FY14 = 0  where DEN_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set DEN_SC_FY14 = 0  where DEN_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set DET_HC_FY14 = 0  where DET_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set DET_SC_FY14 = 0  where DET_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set HQ_HC_FY14 = 0  where HQ_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set HQ_SC_FY14 = 0  where HQ_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set JAX_HC_FY14 = 0  where JAX_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set JAX_SC_FY14 = 0  where JAX_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LR_HC_FY14 = 0  where LR_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LR_SC_FY14 = 0  where LR_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LA_HC_FY14 = 0  where LA_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LA_SC_FY14 = 0  where LA_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LOU_HC_FY14 = 0  where LOU_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LOU_SC_FY14 = 0  where LOU_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIA_HC_FY14 = 0  where MIA_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIA_SC_FY14 = 0  where MIA_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIL_HC_FY14 = 0  where MIL_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIL_SC_FY14 = 0  where MIL_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NH_HC_FY14 = 0  where NH_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NH_SC_FY14 = 0  where NH_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NO_HC_FY14 = 0  where NO_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NO_SC_FY14 = 0  where NO_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NYC_HC_FY14 = 0  where NYC_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NYC_SC_FY14 = 0  where NYC_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set ORL_HC_FY14 = 0  where ORL_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set ORL_SC_FY14 = 0  where ORL_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set PHI_HC_FY14 = 0  where PHI_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set PHI_SC_FY14 = 0  where PHI_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set RI_HC_FY14 = 0  where RI_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set RI_SC_FY14 = 0  where RI_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SAC_HC_FY14 = 0  where SAC_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SAC_SC_FY14 = 0  where SAC_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SA_HC_FY14 = 0  where SA_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SA_SC_FY14 = 0  where SA_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SJ_HC_FY14 = 0  where SJ_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SJ_SC_FY14 = 0  where SJ_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SEA_HC_FY14 = 0  where SEA_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SEA_SC_FY14 = 0  where SEA_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set TUL_HC_FY14 = 0  where TUL_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set TUL_SC_FY14 = 0  where TUL_SC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set WASH_HC_FY14 = 0  where WASH_HC_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set WASH_SC_FY14 = 0  where WASH_SC_FY14 is null



	update ODW.Recent_History.DimRecentGivingFY15 set BR_HC_FY15 = 0  where BR_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set BR_SC_FY15 = 0  where BR_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set BOS_HC_FY15 = 0  where BOS_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set BOS_SC_FY15 = 0  where BOS_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CF_HC_FY15 = 0  where CF_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CF_SC_FY15 = 0  where CF_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CHI_HC_FY15 = 0  where CHI_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CHI_SC_FY15 = 0  where CHI_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CLE_HC_FY15 = 0  where CLE_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CLE_SC_FY15 = 0  where CLE_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CIA_HC_FY15 = 0  where CIA_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CIA_SC_FY15 = 0  where CIA_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CUS_HC_FY15 = 0  where CUS_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CUS_SC_FY15 = 0  where CUS_SC_FY15 is null

	update ODW.Recent_History.DimRecentGivingFY15 set DAL_HC_FY15 = 0  where DAL_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set DAL_SC_FY15 = 0  where DAL_SC_FY15 is null


	update ODW.Recent_History.DimRecentGivingFY15 set DEN_HC_FY15 = 0  where DEN_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set DEN_SC_FY15 = 0  where DEN_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set DET_HC_FY15 = 0  where DET_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set DET_SC_FY15 = 0  where DET_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set HQ_HC_FY15 = 0  where HQ_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set HQ_SC_FY15 = 0  where HQ_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set JAX_HC_FY15 = 0  where JAX_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set JAX_SC_FY15 = 0  where JAX_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LR_HC_FY15 = 0  where LR_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LR_SC_FY15 = 0  where LR_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LA_HC_FY15 = 0  where LA_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LA_SC_FY15 = 0  where LA_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LOU_HC_FY15 = 0  where LOU_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LOU_SC_FY15 = 0  where LOU_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIA_HC_FY15 = 0  where MIA_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIA_SC_FY15 = 0  where MIA_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIL_HC_FY15 = 0  where MIL_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIL_SC_FY15 = 0  where MIL_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NH_HC_FY15 = 0  where NH_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NH_SC_FY15 = 0  where NH_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NO_HC_FY15 = 0  where NO_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NO_SC_FY15 = 0  where NO_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NYC_HC_FY15 = 0  where NYC_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NYC_SC_FY15 = 0  where NYC_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set ORL_HC_FY15 = 0  where ORL_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set ORL_SC_FY15 = 0  where ORL_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set PHI_HC_FY15 = 0  where PHI_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set PHI_SC_FY15 = 0  where PHI_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set RI_HC_FY15 = 0  where RI_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set RI_SC_FY15 = 0  where RI_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SAC_HC_FY15 = 0  where SAC_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SAC_SC_FY15 = 0  where SAC_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SA_HC_FY15 = 0  where SA_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SA_SC_FY15 = 0  where SA_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SJ_HC_FY15 = 0  where SJ_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SJ_SC_FY15 = 0  where SJ_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SEA_HC_FY15 = 0  where SEA_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SEA_SC_FY15 = 0  where SEA_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set TUL_HC_FY15 = 0  where TUL_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set TUL_SC_FY15 = 0  where TUL_SC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set WASH_HC_FY15 = 0  where WASH_HC_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set WASH_SC_FY15 = 0  where WASH_SC_FY15 is null

	
	update ODW.Recent_History.DimRecentGivingFY16 set BR_HC_FY16 = 0  where BR_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set BR_SC_FY16 = 0  where BR_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set BOS_HC_FY16 = 0  where BOS_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set BOS_SC_FY16 = 0  where BOS_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CF_HC_FY16 = 0  where CF_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CF_SC_FY16 = 0  where CF_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CHI_HC_FY16 = 0  where CHI_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CHI_SC_FY16 = 0  where CHI_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CLE_HC_FY16 = 0  where CLE_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CLE_SC_FY16 = 0  where CLE_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CIA_HC_FY16 = 0  where CIA_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CIA_SC_FY16 = 0  where CIA_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CUS_HC_FY16 = 0  where CUS_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CUS_SC_FY16 = 0  where CUS_SC_FY16 is null

	update ODW.Recent_History.DimRecentGivingFY16 set DAL_HC_FY16 = 0  where DAL_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set DAL_SC_FY16 = 0  where DAL_SC_FY16 is null


	update ODW.Recent_History.DimRecentGivingFY16 set DEN_HC_FY16 = 0  where DEN_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set DEN_SC_FY16 = 0  where DEN_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set DET_HC_FY16 = 0  where DET_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set DET_SC_FY16 = 0  where DET_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set HQ_HC_FY16 = 0  where HQ_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set HQ_SC_FY16 = 0  where HQ_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set JAX_HC_FY16 = 0  where JAX_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set JAX_SC_FY16 = 0  where JAX_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LR_HC_FY16 = 0  where LR_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LR_SC_FY16 = 0  where LR_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LA_HC_FY16 = 0  where LA_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LA_SC_FY16 = 0  where LA_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LOU_HC_FY16 = 0  where LOU_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LOU_SC_FY16 = 0  where LOU_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIA_HC_FY16 = 0  where MIA_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIA_SC_FY16 = 0  where MIA_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIL_HC_FY16 = 0  where MIL_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIL_SC_FY16 = 0  where MIL_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NH_HC_FY16 = 0  where NH_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NH_SC_FY16 = 0  where NH_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NO_HC_FY16 = 0  where NO_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NO_SC_FY16 = 0  where NO_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NYC_HC_FY16 = 0  where NYC_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NYC_SC_FY16 = 0  where NYC_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set ORL_HC_FY16 = 0  where ORL_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set ORL_SC_FY16 = 0  where ORL_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set PHI_HC_FY16 = 0  where PHI_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set PHI_SC_FY16 = 0  where PHI_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set RI_HC_FY16 = 0  where RI_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set RI_SC_FY16 = 0  where RI_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SAC_HC_FY16 = 0  where SAC_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SAC_SC_FY16 = 0  where SAC_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SA_HC_FY16 = 0  where SA_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SA_SC_FY16 = 0  where SA_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SJ_HC_FY16 = 0  where SJ_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SJ_SC_FY16 = 0  where SJ_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SEA_HC_FY16 = 0  where SEA_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SEA_SC_FY16 = 0  where SEA_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set TUL_HC_FY16 = 0  where TUL_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set TUL_SC_FY16 = 0  where TUL_SC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set WASH_HC_FY16 = 0  where WASH_HC_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set WASH_SC_FY16 = 0  where WASH_SC_FY16 is null



	update ODW.Recent_History.DimRecentGivingFY17 set BR_HC_FY17 = 0  where BR_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set BR_SC_FY17 = 0  where BR_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set BOS_HC_FY17 = 0  where BOS_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set BOS_SC_FY17 = 0  where BOS_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CF_HC_FY17 = 0  where CF_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CF_SC_FY17 = 0  where CF_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CHI_HC_FY17 = 0  where CHI_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CHI_SC_FY17 = 0  where CHI_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CLE_HC_FY17 = 0  where CLE_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CLE_SC_FY17 = 0  where CLE_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CIA_HC_FY17 = 0  where CIA_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CIA_SC_FY17 = 0  where CIA_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CUS_HC_FY17 = 0  where CUS_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CUS_SC_FY17 = 0  where CUS_SC_FY17 is null

	update ODW.Recent_History.DimRecentGivingFY17 set DAL_HC_FY17 = 0  where DAL_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set DAL_SC_FY17 = 0  where DAL_SC_FY17 is null


	update ODW.Recent_History.DimRecentGivingFY17 set DEN_HC_FY17 = 0  where DEN_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set DEN_SC_FY17 = 0  where DEN_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set DET_HC_FY17 = 0  where DET_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set DET_SC_FY17 = 0  where DET_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set HQ_HC_FY17 = 0  where HQ_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set HQ_SC_FY17 = 0  where HQ_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set JAX_HC_FY17 = 0  where JAX_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set JAX_SC_FY17 = 0  where JAX_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LR_HC_FY17 = 0  where LR_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LR_SC_FY17 = 0  where LR_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LA_HC_FY17 = 0  where LA_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LA_SC_FY17 = 0  where LA_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LOU_HC_FY17 = 0  where LOU_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LOU_SC_FY17 = 0  where LOU_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIA_HC_FY17 = 0  where MIA_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIA_SC_FY17 = 0  where MIA_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIL_HC_FY17 = 0  where MIL_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIL_SC_FY17 = 0  where MIL_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NH_HC_FY17 = 0  where NH_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NH_SC_FY17 = 0  where NH_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NO_HC_FY17 = 0  where NO_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NO_SC_FY17 = 0  where NO_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NYC_HC_FY17 = 0  where NYC_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NYC_SC_FY17 = 0  where NYC_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set ORL_HC_FY17 = 0  where ORL_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set ORL_SC_FY17 = 0  where ORL_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set PHI_HC_FY17 = 0  where PHI_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set PHI_SC_FY17 = 0  where PHI_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set RI_HC_FY17 = 0  where RI_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set RI_SC_FY17 = 0  where RI_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SAC_HC_FY17 = 0  where SAC_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SAC_SC_FY17 = 0  where SAC_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SA_HC_FY17 = 0  where SA_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SA_SC_FY17 = 0  where SA_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SJ_HC_FY17 = 0  where SJ_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SJ_SC_FY17 = 0  where SJ_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SEA_HC_FY17 = 0  where SEA_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SEA_SC_FY17 = 0  where SEA_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set TUL_HC_FY17 = 0  where TUL_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set TUL_SC_FY17 = 0  where TUL_SC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set WASH_HC_FY17 = 0  where WASH_HC_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set WASH_SC_FY17 = 0  where WASH_SC_FY17 is null



	update ODW.Recent_History.DimRecentGivingFY18 set BR_HC_FY18 = 0  where BR_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set BR_SC_FY18 = 0  where BR_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set BOS_HC_FY18 = 0  where BOS_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set BOS_SC_FY18 = 0  where BOS_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CF_HC_FY18 = 0  where CF_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CF_SC_FY18 = 0  where CF_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CHI_HC_FY18 = 0  where CHI_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CHI_SC_FY18 = 0  where CHI_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CLE_HC_FY18 = 0  where CLE_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CLE_SC_FY18 = 0  where CLE_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CIA_HC_FY18 = 0  where CIA_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CIA_SC_FY18 = 0  where CIA_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CUS_HC_FY18 = 0  where CUS_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CUS_SC_FY18 = 0  where CUS_SC_FY18 is null

	update ODW.Recent_History.DimRecentGivingFY18 set DAL_HC_FY18 = 0  where DAL_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set DAL_SC_FY18 = 0  where DAL_SC_FY18 is null


	update ODW.Recent_History.DimRecentGivingFY18 set DEN_HC_FY18 = 0  where DEN_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set DEN_SC_FY18 = 0  where DEN_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set DET_HC_FY18 = 0  where DET_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set DET_SC_FY18 = 0  where DET_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set HQ_HC_FY18 = 0  where HQ_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set HQ_SC_FY18 = 0  where HQ_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set JAX_HC_FY18 = 0  where JAX_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set JAX_SC_FY18 = 0  where JAX_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LR_HC_FY18 = 0  where LR_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LR_SC_FY18 = 0  where LR_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LA_HC_FY18 = 0  where LA_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LA_SC_FY18 = 0  where LA_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LOU_HC_FY18 = 0  where LOU_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LOU_SC_FY18 = 0  where LOU_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIA_HC_FY18 = 0  where MIA_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIA_SC_FY18 = 0  where MIA_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIL_HC_FY18 = 0  where MIL_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIL_SC_FY18 = 0  where MIL_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NH_HC_FY18 = 0  where NH_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NH_SC_FY18 = 0  where NH_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NO_HC_FY18 = 0  where NO_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NO_SC_FY18 = 0  where NO_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NYC_HC_FY18 = 0  where NYC_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NYC_SC_FY18 = 0  where NYC_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set ORL_HC_FY18 = 0  where ORL_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set ORL_SC_FY18 = 0  where ORL_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set PHI_HC_FY18 = 0  where PHI_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set PHI_SC_FY18 = 0  where PHI_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set RI_HC_FY18 = 0  where RI_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set RI_SC_FY18 = 0  where RI_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SAC_HC_FY18 = 0  where SAC_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SAC_SC_FY18 = 0  where SAC_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SA_HC_FY18 = 0  where SA_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SA_SC_FY18 = 0  where SA_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SJ_HC_FY18 = 0  where SJ_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SJ_SC_FY18 = 0  where SJ_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SEA_HC_FY18 = 0  where SEA_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SEA_SC_FY18 = 0  where SEA_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set TUL_HC_FY18 = 0  where TUL_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set TUL_SC_FY18 = 0  where TUL_SC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set WASH_HC_FY18 = 0  where WASH_HC_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set WASH_SC_FY18 = 0  where WASH_SC_FY18 is null



	update ODW.Recent_History.DimRecentGivingFY19 set BR_HC_FY19 = 0  where BR_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set BR_SC_FY19 = 0  where BR_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set BOS_HC_FY19 = 0  where BOS_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set BOS_SC_FY19 = 0  where BOS_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CF_HC_FY19 = 0  where CF_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CF_SC_FY19 = 0  where CF_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CHI_HC_FY19 = 0  where CHI_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CHI_SC_FY19 = 0  where CHI_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CLE_HC_FY19 = 0  where CLE_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CLE_SC_FY19 = 0  where CLE_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CIA_HC_FY19 = 0  where CIA_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CIA_SC_FY19 = 0  where CIA_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CUS_HC_FY19 = 0  where CUS_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CUS_SC_FY19 = 0  where CUS_SC_FY19 is null

	update ODW.Recent_History.DimRecentGivingFY19 set DAL_HC_FY19 = 0  where DAL_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set DAL_SC_FY19 = 0  where DAL_SC_FY19 is null


	update ODW.Recent_History.DimRecentGivingFY19 set DEN_HC_FY19 = 0  where DEN_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set DEN_SC_FY19 = 0  where DEN_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set DET_HC_FY19 = 0  where DET_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set DET_SC_FY19 = 0  where DET_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set HQ_HC_FY19 = 0  where HQ_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set HQ_SC_FY19 = 0  where HQ_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set JAX_HC_FY19 = 0  where JAX_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set JAX_SC_FY19 = 0  where JAX_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LR_HC_FY19 = 0  where LR_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LR_SC_FY19 = 0  where LR_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LA_HC_FY19 = 0  where LA_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LA_SC_FY19 = 0  where LA_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LOU_HC_FY19 = 0  where LOU_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LOU_SC_FY19 = 0  where LOU_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIA_HC_FY19 = 0  where MIA_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIA_SC_FY19 = 0  where MIA_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIL_HC_FY19 = 0  where MIL_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIL_SC_FY19 = 0  where MIL_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NH_HC_FY19 = 0  where NH_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NH_SC_FY19 = 0  where NH_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NO_HC_FY19 = 0  where NO_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NO_SC_FY19 = 0  where NO_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NYC_HC_FY19 = 0  where NYC_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NYC_SC_FY19 = 0  where NYC_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set ORL_HC_FY19 = 0  where ORL_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set ORL_SC_FY19 = 0  where ORL_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set PHI_HC_FY19 = 0  where PHI_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set PHI_SC_FY19 = 0  where PHI_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set RI_HC_FY19 = 0  where RI_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set RI_SC_FY19 = 0  where RI_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SAC_HC_FY19 = 0  where SAC_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SAC_SC_FY19 = 0  where SAC_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SA_HC_FY19 = 0  where SA_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SA_SC_FY19 = 0  where SA_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SJ_HC_FY19 = 0  where SJ_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SJ_SC_FY19 = 0  where SJ_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SEA_HC_FY19 = 0  where SEA_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SEA_SC_FY19 = 0  where SEA_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set TUL_HC_FY19 = 0  where TUL_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set TUL_SC_FY19 = 0  where TUL_SC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set WASH_HC_FY19 = 0  where WASH_HC_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set WASH_SC_FY19 = 0  where WASH_SC_FY19 is null


	update ODW.Recent_History.DimRecentGivingFY20 set BR_HC_FY20 = 0  where BR_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set BR_SC_FY20 = 0  where BR_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set BOS_HC_FY20 = 0  where BOS_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set BOS_SC_FY20 = 0  where BOS_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CF_HC_FY20 = 0  where CF_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CF_SC_FY20 = 0  where CF_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CHI_HC_FY20 = 0  where CHI_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CHI_SC_FY20 = 0  where CHI_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CLE_HC_FY20 = 0  where CLE_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CLE_SC_FY20 = 0  where CLE_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CIA_HC_FY20 = 0  where CIA_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CIA_SC_FY20 = 0  where CIA_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CUS_HC_FY20 = 0  where CUS_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CUS_SC_FY20 = 0  where CUS_SC_FY20 is null

	update ODW.Recent_History.DimRecentGivingFY20 set DAL_HC_FY20 = 0  where DAL_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set DAL_SC_FY20 = 0  where DAL_SC_FY20 is null


	update ODW.Recent_History.DimRecentGivingFY20 set DEN_HC_FY20 = 0  where DEN_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set DEN_SC_FY20 = 0  where DEN_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set DET_HC_FY20 = 0  where DET_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set DET_SC_FY20 = 0  where DET_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set HQ_HC_FY20 = 0  where HQ_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set HQ_SC_FY20 = 0  where HQ_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set JAX_HC_FY20 = 0  where JAX_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set JAX_SC_FY20 = 0  where JAX_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LR_HC_FY20 = 0  where LR_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LR_SC_FY20 = 0  where LR_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LA_HC_FY20 = 0  where LA_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LA_SC_FY20 = 0  where LA_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LOU_HC_FY20 = 0  where LOU_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LOU_SC_FY20 = 0  where LOU_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIA_HC_FY20 = 0  where MIA_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIA_SC_FY20 = 0  where MIA_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIL_HC_FY20 = 0  where MIL_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIL_SC_FY20 = 0  where MIL_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NH_HC_FY20 = 0  where NH_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NH_SC_FY20 = 0  where NH_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NO_HC_FY20 = 0  where NO_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NO_SC_FY20 = 0  where NO_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NYC_HC_FY20 = 0  where NYC_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NYC_SC_FY20 = 0  where NYC_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set ORL_HC_FY20 = 0  where ORL_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set ORL_SC_FY20 = 0  where ORL_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set PHI_HC_FY20 = 0  where PHI_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set PHI_SC_FY20 = 0  where PHI_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set RI_HC_FY20 = 0  where RI_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set RI_SC_FY20 = 0  where RI_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SAC_HC_FY20 = 0  where SAC_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SAC_SC_FY20 = 0  where SAC_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SA_HC_FY20 = 0  where SA_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SA_SC_FY20 = 0  where SA_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SJ_HC_FY20 = 0  where SJ_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SJ_SC_FY20 = 0  where SJ_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SEA_HC_FY20 = 0  where SEA_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SEA_SC_FY20 = 0  where SEA_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set TUL_HC_FY20 = 0  where TUL_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set TUL_SC_FY20 = 0  where TUL_SC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set WASH_HC_FY20 = 0  where WASH_HC_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set WASH_SC_FY20 = 0  where WASH_SC_FY20 is null


	update ODW.Recent_History.DimTotalGiving set BR_HC_Total = 0  where BR_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set BR_SC_Total = 0  where BR_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set BOS_HC_Total = 0  where BOS_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set BOS_SC_Total = 0  where BOS_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set CF_HC_Total = 0  where CF_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set CF_SC_Total = 0  where CF_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set CHI_HC_Total = 0  where CHI_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set CHI_SC_Total = 0  where CHI_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set CLE_HC_Total = 0  where CLE_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set CLE_SC_Total = 0  where CLE_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set CIA_HC_Total = 0  where CIA_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set CIA_SC_Total = 0  where CIA_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set CUS_HC_Total = 0  where CUS_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set CUS_SC_Total = 0  where CUS_SC_Total is null

	update ODW.Recent_History.DimTotalGiving set DAL_HC_Total = 0  where DAL_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set DAL_SC_Total = 0  where DAL_SC_Total is null

	update ODW.Recent_History.DimTotalGiving set DEN_HC_Total = 0  where DEN_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set DEN_SC_Total = 0  where DEN_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set DET_HC_Total = 0  where DET_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set DET_SC_Total = 0  where DET_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set HQ_HC_Total = 0  where HQ_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set HQ_SC_Total = 0  where HQ_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set JAX_HC_Total = 0  where JAX_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set JAX_SC_Total = 0  where JAX_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set LR_HC_Total = 0  where LR_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set LR_SC_Total = 0  where LR_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set LA_HC_Total = 0  where LA_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set LA_SC_Total = 0  where LA_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set LOU_HC_Total = 0  where LOU_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set LOU_SC_Total = 0  where LOU_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set MIA_HC_Total = 0  where MIA_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set MIA_SC_Total = 0  where MIA_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set MIL_HC_Total = 0  where MIL_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set MIL_SC_Total = 0  where MIL_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set NH_HC_Total = 0  where NH_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set NH_SC_Total = 0  where NH_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set NO_HC_Total = 0  where NO_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set NO_SC_Total = 0  where NO_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set NYC_HC_Total = 0  where NYC_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set NYC_SC_Total = 0  where NYC_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set ORL_HC_Total = 0  where ORL_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set ORL_SC_Total = 0  where ORL_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set PHI_HC_Total = 0  where PHI_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set PHI_SC_Total = 0  where PHI_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set RI_HC_Total = 0  where RI_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set RI_SC_Total = 0  where RI_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set SAC_HC_Total = 0  where SAC_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set SAC_SC_Total = 0  where SAC_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set SA_HC_Total = 0  where SA_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set SA_SC_Total = 0  where SA_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set SJ_HC_Total = 0  where SJ_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set SJ_SC_Total = 0  where SJ_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set SEA_HC_Total = 0  where SEA_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set SEA_SC_Total = 0  where SEA_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set TUL_HC_Total = 0  where TUL_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set TUL_SC_Total = 0  where TUL_SC_Total is null
	update ODW.Recent_History.DimTotalGiving set WASH_HC_Total = 0  where WASH_HC_Total is null
	update ODW.Recent_History.DimTotalGiving set WASH_SC_Total = 0  where WASH_SC_Total is null

	update ODW.Recent_History.DimRecentGivingFY20 set BR_PandT_FY20 = 0 where BR_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set BOS_PandT_FY20 = 0 where BOS_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CF_PandT_FY20 = 0 where CF_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CHI_PandT_FY20 = 0 where CHI_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CLE_PandT_FY20 = 0 where CLE_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CIA_PandT_FY20 = 0 where CIA_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set CUS_PandT_FY20 = 0 where CUS_PandT_FY20 is null

	update ODW.Recent_History.DimRecentGivingFY20 set DAL_PandT_FY20 = 0 where DAL_PandT_FY20 is null

	update ODW.Recent_History.DimRecentGivingFY20 set DEN_PandT_FY20 = 0 where DEN_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set DET_PandT_FY20 = 0 where DET_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set HQ_PandT_FY20 = 0 where HQ_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set JAX_PandT_FY20 = 0 where JAX_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LR_PandT_FY20 = 0 where LR_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LA_PandT_FY20 = 0 where LA_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set LOU_PandT_FY20 = 0 where LOU_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIA_PandT_FY20 = 0 where MIA_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set MIL_PandT_FY20 = 0 where MIL_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NH_PandT_FY20 = 0 where NH_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NO_PandT_FY20 = 0 where NO_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set NYC_PandT_FY20 = 0 where NYC_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set ORL_PandT_FY20 = 0 where ORL_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set PHI_PandT_FY20 = 0 where PHI_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set RI_PandT_FY20 = 0 where RI_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SAC_PandT_FY20 = 0 where SAC_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SA_PandT_FY20 = 0 where SA_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SJ_PandT_FY20 = 0 where SJ_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set SEA_PandT_FY20 = 0 where SEA_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set TUL_PandT_FY20 = 0 where TUL_PandT_FY20 is null
	update ODW.Recent_History.DimRecentGivingFY20 set WASH_PandT_FY20 = 0 where WASH_PandT_FY20 is null


	update ODW.Recent_History.DimRecentGivingFY19 set BR_PandT_FY19 = 0 where BR_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set BOS_PandT_FY19 = 0 where BOS_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CF_PandT_FY19 = 0 where CF_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CHI_PandT_FY19 = 0 where CHI_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CLE_PandT_FY19 = 0 where CLE_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CIA_PandT_FY19 = 0 where CIA_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set CUS_PandT_FY19 = 0 where CUS_PandT_FY19 is null

	update ODW.Recent_History.DimRecentGivingFY19 set DAL_PandT_FY19 = 0 where DAL_PandT_FY19 is null

	update ODW.Recent_History.DimRecentGivingFY19 set DEN_PandT_FY19 = 0 where DEN_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set DET_PandT_FY19 = 0 where DET_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set HQ_PandT_FY19 = 0 where HQ_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set JAX_PandT_FY19 = 0 where JAX_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LR_PandT_FY19 = 0 where LR_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LA_PandT_FY19 = 0 where LA_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set LOU_PandT_FY19 = 0 where LOU_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIA_PandT_FY19 = 0 where MIA_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set MIL_PandT_FY19 = 0 where MIL_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NH_PandT_FY19 = 0 where NH_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NO_PandT_FY19 = 0 where NO_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set NYC_PandT_FY19 = 0 where NYC_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set ORL_PandT_FY19 = 0 where ORL_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set PHI_PandT_FY19 = 0 where PHI_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set RI_PandT_FY19 = 0 where RI_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SAC_PandT_FY19 = 0 where SAC_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SA_PandT_FY19 = 0 where SA_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SJ_PandT_FY19 = 0 where SJ_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set SEA_PandT_FY19 = 0 where SEA_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set TUL_PandT_FY19 = 0 where TUL_PandT_FY19 is null
	update ODW.Recent_History.DimRecentGivingFY19 set WASH_PandT_FY19 = 0 where WASH_PandT_FY19 is null


	update ODW.Recent_History.DimRecentGivingFY18 set BR_PandT_FY18 = 0 where BR_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set BOS_PandT_FY18 = 0 where BOS_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CF_PandT_FY18 = 0 where CF_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CHI_PandT_FY18 = 0 where CHI_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CLE_PandT_FY18 = 0 where CLE_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CIA_PandT_FY18 = 0 where CIA_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set CUS_PandT_FY18 = 0 where CUS_PandT_FY18 is null

	update ODW.Recent_History.DimRecentGivingFY18 set DAL_PandT_FY18 = 0 where DAL_PandT_FY18 is null

	update ODW.Recent_History.DimRecentGivingFY18 set DEN_PandT_FY18 = 0 where DEN_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set DET_PandT_FY18 = 0 where DET_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set HQ_PandT_FY18 = 0 where HQ_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set JAX_PandT_FY18 = 0 where JAX_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LR_PandT_FY18 = 0 where LR_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LA_PandT_FY18 = 0 where LA_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set LOU_PandT_FY18 = 0 where LOU_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIA_PandT_FY18 = 0 where MIA_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set MIL_PandT_FY18 = 0 where MIL_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NH_PandT_FY18 = 0 where NH_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NO_PandT_FY18 = 0 where NO_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set NYC_PandT_FY18 = 0 where NYC_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set ORL_PandT_FY18 = 0 where ORL_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set PHI_PandT_FY18 = 0 where PHI_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set RI_PandT_FY18 = 0 where RI_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SAC_PandT_FY18 = 0 where SAC_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SA_PandT_FY18 = 0 where SA_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SJ_PandT_FY18 = 0 where SJ_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set SEA_PandT_FY18 = 0 where SEA_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set TUL_PandT_FY18 = 0 where TUL_PandT_FY18 is null
	update ODW.Recent_History.DimRecentGivingFY18 set WASH_PandT_FY18 = 0 where WASH_PandT_FY18 is null


	update ODW.Recent_History.DimRecentGivingFY17 set BR_PandT_FY17 = 0 where BR_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set BOS_PandT_FY17 = 0 where BOS_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CF_PandT_FY17 = 0 where CF_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CHI_PandT_FY17 = 0 where CHI_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CLE_PandT_FY17 = 0 where CLE_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CIA_PandT_FY17 = 0 where CIA_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set CUS_PandT_FY17 = 0 where CUS_PandT_FY17 is null

	update ODW.Recent_History.DimRecentGivingFY17 set DAL_PandT_FY17 = 0 where DAL_PandT_FY17 is null

	update ODW.Recent_History.DimRecentGivingFY17 set DEN_PandT_FY17 = 0 where DEN_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set DET_PandT_FY17 = 0 where DET_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set HQ_PandT_FY17 = 0 where HQ_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set JAX_PandT_FY17 = 0 where JAX_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LR_PandT_FY17 = 0 where LR_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LA_PandT_FY17 = 0 where LA_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set LOU_PandT_FY17 = 0 where LOU_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIA_PandT_FY17 = 0 where MIA_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set MIL_PandT_FY17 = 0 where MIL_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NH_PandT_FY17 = 0 where NH_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NO_PandT_FY17 = 0 where NO_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set NYC_PandT_FY17 = 0 where NYC_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set ORL_PandT_FY17 = 0 where ORL_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set PHI_PandT_FY17 = 0 where PHI_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set RI_PandT_FY17 = 0 where RI_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SAC_PandT_FY17 = 0 where SAC_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SA_PandT_FY17 = 0 where SA_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SJ_PandT_FY17 = 0 where SJ_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set SEA_PandT_FY17 = 0 where SEA_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set TUL_PandT_FY17 = 0 where TUL_PandT_FY17 is null
	update ODW.Recent_History.DimRecentGivingFY17 set WASH_PandT_FY17 = 0 where WASH_PandT_FY17 is null


	update ODW.Recent_History.DimRecentGivingFY16 set BR_PandT_FY16 = 0 where BR_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set BOS_PandT_FY16 = 0 where BOS_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CF_PandT_FY16 = 0 where CF_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CHI_PandT_FY16 = 0 where CHI_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CLE_PandT_FY16 = 0 where CLE_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CIA_PandT_FY16 = 0 where CIA_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set CUS_PandT_FY16 = 0 where CUS_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set DEN_PandT_FY16 = 0 where DEN_PandT_FY16 is null

	update ODW.Recent_History.DimRecentGivingFY16 set DAL_PandT_FY16 = 0 where DAL_PandT_FY16 is null

	update ODW.Recent_History.DimRecentGivingFY16 set DET_PandT_FY16 = 0 where DET_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set HQ_PandT_FY16 = 0 where HQ_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set JAX_PandT_FY16 = 0 where JAX_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LR_PandT_FY16 = 0 where LR_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LA_PandT_FY16 = 0 where LA_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set LOU_PandT_FY16 = 0 where LOU_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIA_PandT_FY16 = 0 where MIA_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set MIL_PandT_FY16 = 0 where MIL_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NH_PandT_FY16 = 0 where NH_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NO_PandT_FY16 = 0 where NO_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set NYC_PandT_FY16 = 0 where NYC_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set ORL_PandT_FY16 = 0 where ORL_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set PHI_PandT_FY16 = 0 where PHI_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set RI_PandT_FY16 = 0 where RI_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SAC_PandT_FY16 = 0 where SAC_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SA_PandT_FY16 = 0 where SA_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SJ_PandT_FY16 = 0 where SJ_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set SEA_PandT_FY16 = 0 where SEA_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set TUL_PandT_FY16 = 0 where TUL_PandT_FY16 is null
	update ODW.Recent_History.DimRecentGivingFY16 set WASH_PandT_FY16 = 0 where WASH_PandT_FY16 is null


	update ODW.Recent_History.DimRecentGivingFY15 set BR_PandT_FY15 = 0 where BR_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set BOS_PandT_FY15 = 0 where BOS_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CF_PandT_FY15 = 0 where CF_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CHI_PandT_FY15 = 0 where CHI_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CLE_PandT_FY15 = 0 where CLE_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CIA_PandT_FY15 = 0 where CIA_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set CUS_PandT_FY15 = 0 where CUS_PandT_FY15 is null

	update ODW.Recent_History.DimRecentGivingFY15 set DAL_PandT_FY15 = 0 where DAL_PandT_FY15 is null

	update ODW.Recent_History.DimRecentGivingFY15 set DEN_PandT_FY15 = 0 where DEN_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set DET_PandT_FY15 = 0 where DET_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set HQ_PandT_FY15 = 0 where HQ_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set JAX_PandT_FY15 = 0 where JAX_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LR_PandT_FY15 = 0 where LR_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LA_PandT_FY15 = 0 where LA_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set LOU_PandT_FY15 = 0 where LOU_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIA_PandT_FY15 = 0 where MIA_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set MIL_PandT_FY15 = 0 where MIL_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NH_PandT_FY15 = 0 where NH_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NO_PandT_FY15 = 0 where NO_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set NYC_PandT_FY15 = 0 where NYC_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set ORL_PandT_FY15 = 0 where ORL_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set PHI_PandT_FY15 = 0 where PHI_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set RI_PandT_FY15 = 0 where RI_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SAC_PandT_FY15 = 0 where SAC_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SA_PandT_FY15 = 0 where SA_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SJ_PandT_FY15 = 0 where SJ_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set SEA_PandT_FY15 = 0 where SEA_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set TUL_PandT_FY15 = 0 where TUL_PandT_FY15 is null
	update ODW.Recent_History.DimRecentGivingFY15 set WASH_PandT_FY15 = 0 where WASH_PandT_FY15 is null


	update ODW.Recent_History.DimRecentGivingFY14 set BR_PandT_FY14 = 0 where BR_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set BOS_PandT_FY14 = 0 where BOS_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CF_PandT_FY14 = 0 where CF_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CHI_PandT_FY14 = 0 where CHI_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CLE_PandT_FY14 = 0 where CLE_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CIA_PandT_FY14 = 0 where CIA_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set CUS_PandT_FY14 = 0 where CUS_PandT_FY14 is null



	update ODW.Recent_History.DimRecentGivingFY14 set DEN_PandT_FY14 = 0 where DEN_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set DET_PandT_FY14 = 0 where DET_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set HQ_PandT_FY14 = 0 where HQ_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set JAX_PandT_FY14 = 0 where JAX_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LR_PandT_FY14 = 0 where LR_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LA_PandT_FY14 = 0 where LA_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set LOU_PandT_FY14 = 0 where LOU_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIA_PandT_FY14 = 0 where MIA_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set MIL_PandT_FY14 = 0 where MIL_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NH_PandT_FY14 = 0 where NH_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NO_PandT_FY14 = 0 where NO_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set NYC_PandT_FY14 = 0 where NYC_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set ORL_PandT_FY14 = 0 where ORL_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set PHI_PandT_FY14 = 0 where PHI_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set RI_PandT_FY14 = 0 where RI_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SAC_PandT_FY14 = 0 where SAC_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SA_PandT_FY14 = 0 where SA_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SJ_PandT_FY14 = 0 where SJ_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set SEA_PandT_FY14 = 0 where SEA_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set TUL_PandT_FY14 = 0 where TUL_PandT_FY14 is null
	update ODW.Recent_History.DimRecentGivingFY14 set WASH_PandT_FY14 = 0 where WASH_PandT_FY14 is null

	select a.AccountID 
	into #Gave_To_Chicago_FY14
	from Recent_History.DimRecentGivingFY14 (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.AccountID
	where (CHI_HC_FY14 + CHI_SC_FY14) > 0 and b.[Account Type] = 'Household'
	-- 488

	select a.AccountID
	into #Gave_To_Chicago_FY15
	from Recent_History.DimRecentGivingFY15 (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.AccountID = b.AccountID
	where (CHI_HC_FY15 + CHI_SC_FY15) > 0 and b.[Account Type] = 'Household'
	-- 129

	select a.AccountID
	into #Gave_To_Chicago_FY14_Not_FY15
	from #Gave_To_Chicago_FY14 (nolock) a
	left outer join #Gave_To_Chicago_FY15 (nolock) b on a.AccountID = b.AccountID
	where b.AccountID is null

	update ODW.dbo.DimAccount set Gave_To_Chicago_FY14_Not_FY15 = 'No'
	update ODW.dbo.DimAccount 
	set Gave_To_Chicago_FY14_Not_FY15 = 'Yes'
	from ODW.dbo.DimAccount (nolock) a
	inner join #Gave_To_Chicago_FY14_Not_FY15 (nolock) b on a.AccountID = b.AccountID

	update ODW.dbo.DimAccount set BOS_Holiday_Card_Differential = 'No'

	select distinct AccountID
	into #BOS_Recent_Closings
	from 
	(select a.AccountID, replace([CY Allocation Location String], 'City Year ', '') BUsinessUnit, 
	sum(Hard) Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	inner join DimCampaign (nolock) c on a.OppCampaignID = c.[Campaign ID]
	where Hard > 0 
	and cast(a.[Close Date] as date) between @Boston_Recent_Start and @Boston_Recent_End
	and replace([CY Allocation Location String], 'City Year ', '') = 'Boston'
	and	c.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and a.Stage not in ('Canceled','Suspended','Uncollectible')
	group by a.AccountID, [CY Allocation Location String]
	UNION ALL
	select d.AccountID, c.[General Accounting Unit Name] BusinessUnit, 
	sum(c.[Amount]) as Soft
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	and cast(b.[Close Date] as date) between cast('11/26/2014' as date) and cast('12/5/2014' as date)
	and c.[General Accounting Unit Name] = 'Boston'
	group by d.AccountID, c.[General Accounting Unit Name]) a
	order by AccountID

	update ODW.dbo.DimAccount 
	set BOS_Holiday_Card_Differential = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join #BOS_Recent_Closings (nolock) b on a.AccountID = b.AccountID

	update ODW.Recent_History.DimRecentGivingFY05
	set TOTAL_FY05 = [BR_HC_FY05] + [BR_SC_FY05] + [BOS_HC_FY05] + [BOS_SC_FY05] + [CF_HC_FY05] + [CF_SC_FY05] + [CHI_HC_FY05] + [CHI_SC_FY05] + [CLE_HC_FY05] + [CLE_SC_FY05] + [CIA_HC_FY05] + [CIA_SC_FY05] + [CUS_HC_FY05] + [CUS_SC_FY05] + [DEN_HC_FY05] + [DEN_SC_FY05] + [DET_HC_FY05] + [DET_SC_FY05] + [HQ_HC_FY05] + [HQ_SC_FY05] + [JAX_HC_FY05] + [JAX_SC_FY05] + [LR_HC_FY05] + [LR_SC_FY05] + [LA_HC_FY05] + [LA_SC_FY05] + [LOU_HC_FY05] + [LOU_SC_FY05] + [MIA_HC_FY05] + [MIA_SC_FY05] + [MIL_HC_FY05] + [MIL_SC_FY05] + [NH_HC_FY05] + [NH_SC_FY05] + [NO_HC_FY05] + [NO_SC_FY05] + [NYC_HC_FY05] + [NYC_SC_FY05] + [ORL_HC_FY05] + [ORL_SC_FY05] + [PHI_HC_FY05] + [PHI_SC_FY05] + [RI_HC_FY05] + [RI_SC_FY05] + [SAC_HC_FY05] + [SAC_SC_FY05] + [SA_HC_FY05] + [SA_SC_FY05] + [SJ_HC_FY05] + [SJ_SC_FY05] + [SEA_HC_FY05] + [SEA_SC_FY05] + [TUL_HC_FY05] + [TUL_SC_FY05] + [WASH_HC_FY05] + [WASH_SC_FY05]

	update ODW.Recent_History.DimRecentGivingFY06
	set TOTAL_FY06 = [BR_HC_FY06] + [BR_SC_FY06] + [BOS_HC_FY06] + [BOS_SC_FY06] + [CF_HC_FY06] + [CF_SC_FY06] + [CHI_HC_FY06] + [CHI_SC_FY06] + [CLE_HC_FY06] + [CLE_SC_FY06] + [CIA_HC_FY06] + [CIA_SC_FY06] + [CUS_HC_FY06] + [CUS_SC_FY06] + [DEN_HC_FY06] + [DEN_SC_FY06] + [DET_HC_FY06] + [DET_SC_FY06] + [HQ_HC_FY06] + [HQ_SC_FY06] + [JAX_HC_FY06] + [JAX_SC_FY06] + [LR_HC_FY06] + [LR_SC_FY06] + [LA_HC_FY06] + [LA_SC_FY06] + [LOU_HC_FY06] + [LOU_SC_FY06] + [MIA_HC_FY06] + [MIA_SC_FY06] + [MIL_HC_FY06] + [MIL_SC_FY06] + [NH_HC_FY06] + [NH_SC_FY06] + [NO_HC_FY06] + [NO_SC_FY06] + [NYC_HC_FY06] + [NYC_SC_FY06] + [ORL_HC_FY06] + [ORL_SC_FY06] + [PHI_HC_FY06] + [PHI_SC_FY06] + [RI_HC_FY06] + [RI_SC_FY06] + [SAC_HC_FY06] + [SAC_SC_FY06] + [SA_HC_FY06] + [SA_SC_FY06] + [SJ_HC_FY06] + [SJ_SC_FY06] + [SEA_HC_FY06] + [SEA_SC_FY06] + [TUL_HC_FY06] + [TUL_SC_FY06] + [WASH_HC_FY06] + [WASH_SC_FY06]

	update ODW.Recent_History.DimRecentGivingFY07
	set TOTAL_FY07 = [BR_HC_FY07] + [BR_SC_FY07] + [BOS_HC_FY07] + [BOS_SC_FY07] + [CF_HC_FY07] + [CF_SC_FY07] + [CHI_HC_FY07] + [CHI_SC_FY07] + [CLE_HC_FY07] + [CLE_SC_FY07] + [CIA_HC_FY07] + [CIA_SC_FY07] + [CUS_HC_FY07] + [CUS_SC_FY07] + [DEN_HC_FY07] + [DEN_SC_FY07] + [DET_HC_FY07] + [DET_SC_FY07] + [HQ_HC_FY07] + [HQ_SC_FY07] + [JAX_HC_FY07] + [JAX_SC_FY07] + [LR_HC_FY07] + [LR_SC_FY07] + [LA_HC_FY07] + [LA_SC_FY07] + [LOU_HC_FY07] + [LOU_SC_FY07] + [MIA_HC_FY07] + [MIA_SC_FY07] + [MIL_HC_FY07] + [MIL_SC_FY07] + [NH_HC_FY07] + [NH_SC_FY07] + [NO_HC_FY07] + [NO_SC_FY07] + [NYC_HC_FY07] + [NYC_SC_FY07] + [ORL_HC_FY07] + [ORL_SC_FY07] + [PHI_HC_FY07] + [PHI_SC_FY07] + [RI_HC_FY07] + [RI_SC_FY07] + [SAC_HC_FY07] + [SAC_SC_FY07] + [SA_HC_FY07] + [SA_SC_FY07] + [SJ_HC_FY07] + [SJ_SC_FY07] + [SEA_HC_FY07] + [SEA_SC_FY07] + [TUL_HC_FY07] + [TUL_SC_FY07] + [WASH_HC_FY07] + [WASH_SC_FY07]

	update ODW.Recent_History.DimRecentGivingFY08
	set TOTAL_FY08 = [BR_HC_FY08] + [BR_SC_FY08] + [BOS_HC_FY08] + [BOS_SC_FY08] + [CF_HC_FY08] + [CF_SC_FY08] + [CHI_HC_FY08] + [CHI_SC_FY08] + [CLE_HC_FY08] + [CLE_SC_FY08] + [CIA_HC_FY08] + [CIA_SC_FY08] + [CUS_HC_FY08] + [CUS_SC_FY08] + [DEN_HC_FY08] + [DEN_SC_FY08] + [DET_HC_FY08] + [DET_SC_FY08] + [HQ_HC_FY08] + [HQ_SC_FY08] + [JAX_HC_FY08] + [JAX_SC_FY08] + [LR_HC_FY08] + [LR_SC_FY08] + [LA_HC_FY08] + [LA_SC_FY08] + [LOU_HC_FY08] + [LOU_SC_FY08] + [MIA_HC_FY08] + [MIA_SC_FY08] + [MIL_HC_FY08] + [MIL_SC_FY08] + [NH_HC_FY08] + [NH_SC_FY08] + [NO_HC_FY08] + [NO_SC_FY08] + [NYC_HC_FY08] + [NYC_SC_FY08] + [ORL_HC_FY08] + [ORL_SC_FY08] + [PHI_HC_FY08] + [PHI_SC_FY08] + [RI_HC_FY08] + [RI_SC_FY08] + [SAC_HC_FY08] + [SAC_SC_FY08] + [SA_HC_FY08] + [SA_SC_FY08] + [SJ_HC_FY08] + [SJ_SC_FY08] + [SEA_HC_FY08] + [SEA_SC_FY08] + [TUL_HC_FY08] + [TUL_SC_FY08] + [WASH_HC_FY08] + [WASH_SC_FY08]

	update ODW.Recent_History.DimRecentGivingFY09
	set TOTAL_FY09 = [BR_HC_FY09] + [BR_SC_FY09] + [BOS_HC_FY09] + [BOS_SC_FY09] + [CF_HC_FY09] + [CF_SC_FY09] + [CHI_HC_FY09] + [CHI_SC_FY09] + [CLE_HC_FY09] + [CLE_SC_FY09] + [CIA_HC_FY09] + [CIA_SC_FY09] + [CUS_HC_FY09] + [CUS_SC_FY09] + [DEN_HC_FY09] + [DEN_SC_FY09] + [DET_HC_FY09] + [DET_SC_FY09] + [HQ_HC_FY09] + [HQ_SC_FY09] + [JAX_HC_FY09] + [JAX_SC_FY09] + [LR_HC_FY09] + [LR_SC_FY09] + [LA_HC_FY09] + [LA_SC_FY09] + [LOU_HC_FY09] + [LOU_SC_FY09] + [MIA_HC_FY09] + [MIA_SC_FY09] + [MIL_HC_FY09] + [MIL_SC_FY09] + [NH_HC_FY09] + [NH_SC_FY09] + [NO_HC_FY09] + [NO_SC_FY09] + [NYC_HC_FY09] + [NYC_SC_FY09] + [ORL_HC_FY09] + [ORL_SC_FY09] + [PHI_HC_FY09] + [PHI_SC_FY09] + [RI_HC_FY09] + [RI_SC_FY09] + [SAC_HC_FY09] + [SAC_SC_FY09] + [SA_HC_FY09] + [SA_SC_FY09] + [SJ_HC_FY09] + [SJ_SC_FY09] + [SEA_HC_FY09] + [SEA_SC_FY09] + [TUL_HC_FY09] + [TUL_SC_FY09] + [WASH_HC_FY09] + [WASH_SC_FY09]

	update ODW.Recent_History.DimRecentGivingFY10
	set TOTAL_FY10 = [BR_HC_FY10] + [BR_SC_FY10] + [BOS_HC_FY10] + [BOS_SC_FY10] + [CF_HC_FY10] + [CF_SC_FY10] + [CHI_HC_FY10] + [CHI_SC_FY10] + [CLE_HC_FY10] + [CLE_SC_FY10] + [CIA_HC_FY10] + [CIA_SC_FY10] + [CUS_HC_FY10] + [CUS_SC_FY10] + [DEN_HC_FY10] + [DEN_SC_FY10] + [DET_HC_FY10] + [DET_SC_FY10] + [HQ_HC_FY10] + [HQ_SC_FY10] + [JAX_HC_FY10] + [JAX_SC_FY10] + [LR_HC_FY10] + [LR_SC_FY10] + [LA_HC_FY10] + [LA_SC_FY10] + [LOU_HC_FY10] + [LOU_SC_FY10] + [MIA_HC_FY10] + [MIA_SC_FY10] + [MIL_HC_FY10] + [MIL_SC_FY10] + [NH_HC_FY10] + [NH_SC_FY10] + [NO_HC_FY10] + [NO_SC_FY10] + [NYC_HC_FY10] + [NYC_SC_FY10] + [ORL_HC_FY10] + [ORL_SC_FY10] + [PHI_HC_FY10] + [PHI_SC_FY10] + [RI_HC_FY10] + [RI_SC_FY10] + [SAC_HC_FY10] + [SAC_SC_FY10] + [SA_HC_FY10] + [SA_SC_FY10] + [SJ_HC_FY10] + [SJ_SC_FY10] + [SEA_HC_FY10] + [SEA_SC_FY10] + [TUL_HC_FY10] + [TUL_SC_FY10] + [WASH_HC_FY10] + [WASH_SC_FY10]

	update ODW.Recent_History.DimRecentGivingFY11
	set TOTAL_FY11 = [BR_HC_FY11] + [BR_SC_FY11] + [BOS_HC_FY11] + [BOS_SC_FY11] + [CF_HC_FY11] + [CF_SC_FY11] + [CHI_HC_FY11] + [CHI_SC_FY11] + [CLE_HC_FY11] + [CLE_SC_FY11] + [CIA_HC_FY11] + [CIA_SC_FY11] + [CUS_HC_FY11] + [CUS_SC_FY11] + [DEN_HC_FY11] + [DEN_SC_FY11] + [DET_HC_FY11] + [DET_SC_FY11] + [HQ_HC_FY11] + [HQ_SC_FY11] + [JAX_HC_FY11] + [JAX_SC_FY11] + [LR_HC_FY11] + [LR_SC_FY11] + [LA_HC_FY11] + [LA_SC_FY11] + [LOU_HC_FY11] + [LOU_SC_FY11] + [MIA_HC_FY11] + [MIA_SC_FY11] + [MIL_HC_FY11] + [MIL_SC_FY11] + [NH_HC_FY11] + [NH_SC_FY11] + [NO_HC_FY11] + [NO_SC_FY11] + [NYC_HC_FY11] + [NYC_SC_FY11] + [ORL_HC_FY11] + [ORL_SC_FY11] + [PHI_HC_FY11] + [PHI_SC_FY11] + [RI_HC_FY11] + [RI_SC_FY11] + [SAC_HC_FY11] + [SAC_SC_FY11] + [SA_HC_FY11] + [SA_SC_FY11] + [SJ_HC_FY11] + [SJ_SC_FY11] + [SEA_HC_FY11] + [SEA_SC_FY11] + [TUL_HC_FY11] + [TUL_SC_FY11] + [WASH_HC_FY11] + [WASH_SC_FY11]

	update ODW.Recent_History.DimRecentGivingFY12
	set TOTAL_FY12 = [BR_HC_FY12] + [BR_SC_FY12] + [BOS_HC_FY12] + [BOS_SC_FY12] + [CF_HC_FY12] + [CF_SC_FY12] + [CHI_HC_FY12] + [CHI_SC_FY12] + [CLE_HC_FY12] + [CLE_SC_FY12] + [CIA_HC_FY12] + [CIA_SC_FY12] + [CUS_HC_FY12] + [CUS_SC_FY12] + [DEN_HC_FY12] + [DEN_SC_FY12] + [DET_HC_FY12] + [DET_SC_FY12] + [HQ_HC_FY12] + [HQ_SC_FY12] + [JAX_HC_FY12] + [JAX_SC_FY12] + [LR_HC_FY12] + [LR_SC_FY12] + [LA_HC_FY12] + [LA_SC_FY12] + [LOU_HC_FY12] + [LOU_SC_FY12] + [MIA_HC_FY12] + [MIA_SC_FY12] + [MIL_HC_FY12] + [MIL_SC_FY12] + [NH_HC_FY12] + [NH_SC_FY12] + [NO_HC_FY12] + [NO_SC_FY12] + [NYC_HC_FY12] + [NYC_SC_FY12] + [ORL_HC_FY12] + [ORL_SC_FY12] + [PHI_HC_FY12] + [PHI_SC_FY12] + [RI_HC_FY12] + [RI_SC_FY12] + [SAC_HC_FY12] + [SAC_SC_FY12] + [SA_HC_FY12] + [SA_SC_FY12] + [SJ_HC_FY12] + [SJ_SC_FY12] + [SEA_HC_FY12] + [SEA_SC_FY12] + [TUL_HC_FY12] + [TUL_SC_FY12] + [WASH_HC_FY12] + [WASH_SC_FY12]

	update ODW.Recent_History.DimRecentGivingFY13
	set TOTAL_FY13 = [BR_HC_FY13] + [BR_SC_FY13] + [BOS_HC_FY13] + [BOS_SC_FY13] + [CF_HC_FY13] + [CF_SC_FY13] + [CHI_HC_FY13] + [CHI_SC_FY13] + [CLE_HC_FY13] + [CLE_SC_FY13] + [CIA_HC_FY13] + [CIA_SC_FY13] + [CUS_HC_FY13] + [CUS_SC_FY13] + [DEN_HC_FY13] + [DEN_SC_FY13] + [DET_HC_FY13] + [DET_SC_FY13] + [HQ_HC_FY13] + [HQ_SC_FY13] + [JAX_HC_FY13] + [JAX_SC_FY13] + [LR_HC_FY13] + [LR_SC_FY13] + [LA_HC_FY13] + [LA_SC_FY13] + [LOU_HC_FY13] + [LOU_SC_FY13] + [MIA_HC_FY13] + [MIA_SC_FY13] + [MIL_HC_FY13] + [MIL_SC_FY13] + [NH_HC_FY13] + [NH_SC_FY13] + [NO_HC_FY13] + [NO_SC_FY13] + [NYC_HC_FY13] + [NYC_SC_FY13] + [ORL_HC_FY13] + [ORL_SC_FY13] + [PHI_HC_FY13] + [PHI_SC_FY13] + [RI_HC_FY13] + [RI_SC_FY13] + [SAC_HC_FY13] + [SAC_SC_FY13] + [SA_HC_FY13] + [SA_SC_FY13] + [SJ_HC_FY13] + [SJ_SC_FY13] + [SEA_HC_FY13] + [SEA_SC_FY13] + [TUL_HC_FY13] + [TUL_SC_FY13] + [WASH_HC_FY13] + [WASH_SC_FY13]

	update ODW.Recent_History.DimRecentGivingFY14
	set TOTAL_FY14 = [BR_HC_FY14] + [BR_SC_FY14] + [BOS_HC_FY14] + [BOS_SC_FY14] + [CF_HC_FY14] + [CF_SC_FY14] + [CHI_HC_FY14] + [CHI_SC_FY14] + [CLE_HC_FY14] + [CLE_SC_FY14] + [CIA_HC_FY14] + [CIA_SC_FY14] + [CUS_HC_FY14] + [CUS_SC_FY14] + [DEN_HC_FY14] + [DEN_SC_FY14] + [DET_HC_FY14] + [DET_SC_FY14] + [HQ_HC_FY14] + [HQ_SC_FY14] + [JAX_HC_FY14] + [JAX_SC_FY14] + [LR_HC_FY14] + [LR_SC_FY14] + [LA_HC_FY14] + [LA_SC_FY14] + [LOU_HC_FY14] + [LOU_SC_FY14] + [MIA_HC_FY14] + [MIA_SC_FY14] + [MIL_HC_FY14] + [MIL_SC_FY14] + [NH_HC_FY14] + [NH_SC_FY14] + [NO_HC_FY14] + [NO_SC_FY14] + [NYC_HC_FY14] + [NYC_SC_FY14] + [ORL_HC_FY14] + [ORL_SC_FY14] + [PHI_HC_FY14] + [PHI_SC_FY14] + [RI_HC_FY14] + [RI_SC_FY14] + [SAC_HC_FY14] + [SAC_SC_FY14] + [SA_HC_FY14] + [SA_SC_FY14] + [SJ_HC_FY14] + [SJ_SC_FY14] + [SEA_HC_FY14] + [SEA_SC_FY14] + [TUL_HC_FY14] + [TUL_SC_FY14] + [WASH_HC_FY14] + [WASH_SC_FY14]

	update ODW.Recent_History.DimRecentGivingFY15
	set TOTAL_FY15 = [BR_HC_FY15] + [BR_SC_FY15] + [BOS_HC_FY15] + [BOS_SC_FY15] + [CF_HC_FY15] + [CF_SC_FY15] + [CHI_HC_FY15] + [CHI_SC_FY15] + [CLE_HC_FY15] + [CLE_SC_FY15] + [CIA_HC_FY15] + [CIA_SC_FY15] + [CUS_HC_FY15] + [CUS_SC_FY15] + [DEN_HC_FY15] + [DEN_SC_FY15] + [DET_HC_FY15] + [DET_SC_FY15] + [HQ_HC_FY15] + [HQ_SC_FY15] + [JAX_HC_FY15] + [JAX_SC_FY15] + [LR_HC_FY15] + [LR_SC_FY15] + [LA_HC_FY15] + [LA_SC_FY15] + [LOU_HC_FY15] + [LOU_SC_FY15] + [MIA_HC_FY15] + [MIA_SC_FY15] + [MIL_HC_FY15] + [MIL_SC_FY15] + [NH_HC_FY15] + [NH_SC_FY15] + [NO_HC_FY15] + [NO_SC_FY15] + [NYC_HC_FY15] + [NYC_SC_FY15] + [ORL_HC_FY15] + [ORL_SC_FY15] + [PHI_HC_FY15] + [PHI_SC_FY15] + [RI_HC_FY15] + [RI_SC_FY15] + [SAC_HC_FY15] + [SAC_SC_FY15] + [SA_HC_FY15] + [SA_SC_FY15] + [SJ_HC_FY15] + [SJ_SC_FY15] + [SEA_HC_FY15] + [SEA_SC_FY15] + [TUL_HC_FY15] + [TUL_SC_FY15] + [WASH_HC_FY15] + [WASH_SC_FY15] + [DAL_HC_FY15] + [DAL_SC_FY15]

	update ODW.Recent_History.DimRecentGivingFY16
	set TOTAL_FY16 = [BR_HC_FY16] + [BR_SC_FY16] + [BOS_HC_FY16] + [BOS_SC_FY16] + [CF_HC_FY16] + [CF_SC_FY16] + [CHI_HC_FY16] + [CHI_SC_FY16] + [CLE_HC_FY16] + [CLE_SC_FY16] + [CIA_HC_FY16] + [CIA_SC_FY16] + [CUS_HC_FY16] + [CUS_SC_FY16] + [DEN_HC_FY16] + [DEN_SC_FY16] + [DET_HC_FY16] + [DET_SC_FY16] + [HQ_HC_FY16] + [HQ_SC_FY16] + [JAX_HC_FY16] + [JAX_SC_FY16] + [LR_HC_FY16] + [LR_SC_FY16] + [LA_HC_FY16] + [LA_SC_FY16] + [LOU_HC_FY16] + [LOU_SC_FY16] + [MIA_HC_FY16] + [MIA_SC_FY16] + [MIL_HC_FY16] + [MIL_SC_FY16] + [NH_HC_FY16] + [NH_SC_FY16] + [NO_HC_FY16] + [NO_SC_FY16] + [NYC_HC_FY16] + [NYC_SC_FY16] + [ORL_HC_FY16] + [ORL_SC_FY16] + [PHI_HC_FY16] + [PHI_SC_FY16] + [RI_HC_FY16] + [RI_SC_FY16] + [SAC_HC_FY16] + [SAC_SC_FY16] + [SA_HC_FY16] + [SA_SC_FY16] + [SJ_HC_FY16] + [SJ_SC_FY16] + [SEA_HC_FY16] + [SEA_SC_FY16] + [TUL_HC_FY16] + [TUL_SC_FY16] + [WASH_HC_FY16] + [WASH_SC_FY16] + [DAL_HC_FY16] + [DAL_SC_FY16]

	update ODW.Recent_History.DimRecentGivingFY17
	set TOTAL_FY17 = [BR_HC_FY17] + [BR_SC_FY17] + [BOS_HC_FY17] + [BOS_SC_FY17] + [CF_HC_FY17] + [CF_SC_FY17] + [CHI_HC_FY17] + [CHI_SC_FY17] + [CLE_HC_FY17] + [CLE_SC_FY17] + [CIA_HC_FY17] + [CIA_SC_FY17] + [CUS_HC_FY17] + [CUS_SC_FY17] + [DEN_HC_FY17] + [DEN_SC_FY17] + [DET_HC_FY17] + [DET_SC_FY17] + [HQ_HC_FY17] + [HQ_SC_FY17] + [JAX_HC_FY17] + [JAX_SC_FY17] + [LR_HC_FY17] + [LR_SC_FY17] + [LA_HC_FY17] + [LA_SC_FY17] + [LOU_HC_FY17] + [LOU_SC_FY17] + [MIA_HC_FY17] + [MIA_SC_FY17] + [MIL_HC_FY17] + [MIL_SC_FY17] + [NH_HC_FY17] + [NH_SC_FY17] + [NO_HC_FY17] + [NO_SC_FY17] + [NYC_HC_FY17] + [NYC_SC_FY17] + [ORL_HC_FY17] + [ORL_SC_FY17] + [PHI_HC_FY17] + [PHI_SC_FY17] + [RI_HC_FY17] + [RI_SC_FY17] + [SAC_HC_FY17] + [SAC_SC_FY17] + [SA_HC_FY17] + [SA_SC_FY17] + [SJ_HC_FY17] + [SJ_SC_FY17] + [SEA_HC_FY17] + [SEA_SC_FY17] + [TUL_HC_FY17] + [TUL_SC_FY17] + [WASH_HC_FY17] + [WASH_SC_FY17] + [DAL_HC_FY17] + [DAL_SC_FY17]

	update ODW.Recent_History.DimRecentGivingFY18
	set TOTAL_FY18 = [BR_HC_FY18] + [BR_SC_FY18] + [BOS_HC_FY18] + [BOS_SC_FY18] + [CF_HC_FY18] + [CF_SC_FY18] + [CHI_HC_FY18] + [CHI_SC_FY18] + [CLE_HC_FY18] + [CLE_SC_FY18] + [CIA_HC_FY18] + [CIA_SC_FY18] + [CUS_HC_FY18] + [CUS_SC_FY18] + [DEN_HC_FY18] + [DEN_SC_FY18] + [DET_HC_FY18] + [DET_SC_FY18] + [HQ_HC_FY18] + [HQ_SC_FY18] + [JAX_HC_FY18] + [JAX_SC_FY18] + [LR_HC_FY18] + [LR_SC_FY18] + [LA_HC_FY18] + [LA_SC_FY18] + [LOU_HC_FY18] + [LOU_SC_FY18] + [MIA_HC_FY18] + [MIA_SC_FY18] + [MIL_HC_FY18] + [MIL_SC_FY18] + [NH_HC_FY18] + [NH_SC_FY18] + [NO_HC_FY18] + [NO_SC_FY18] + [NYC_HC_FY18] + [NYC_SC_FY18] + [ORL_HC_FY18] + [ORL_SC_FY18] + [PHI_HC_FY18] + [PHI_SC_FY18] + [RI_HC_FY18] + [RI_SC_FY18] + [SAC_HC_FY18] + [SAC_SC_FY18] + [SA_HC_FY18] + [SA_SC_FY18] + [SJ_HC_FY18] + [SJ_SC_FY18] + [SEA_HC_FY18] + [SEA_SC_FY18] + [TUL_HC_FY18] + [TUL_SC_FY18] + [WASH_HC_FY18] + [WASH_SC_FY18] + [DAL_HC_FY18] + [DAL_SC_FY18]

	update ODW.Recent_History.DimRecentGivingFY19
	set TOTAL_FY19 = [BR_HC_FY19] + [BR_SC_FY19] + [BOS_HC_FY19] + [BOS_SC_FY19] + [CF_HC_FY19] + [CF_SC_FY19] + [CHI_HC_FY19] + [CHI_SC_FY19] + [CLE_HC_FY19] + [CLE_SC_FY19] + [CIA_HC_FY19] + [CIA_SC_FY19] + [CUS_HC_FY19] + [CUS_SC_FY19] + [DEN_HC_FY19] + [DEN_SC_FY19] + [DET_HC_FY19] + [DET_SC_FY19] + [HQ_HC_FY19] + [HQ_SC_FY19] + [JAX_HC_FY19] + [JAX_SC_FY19] + [LR_HC_FY19] + [LR_SC_FY19] + [LA_HC_FY19] + [LA_SC_FY19] + [LOU_HC_FY19] + [LOU_SC_FY19] + [MIA_HC_FY19] + [MIA_SC_FY19] + [MIL_HC_FY19] + [MIL_SC_FY19] + [NH_HC_FY19] + [NH_SC_FY19] + [NO_HC_FY19] + [NO_SC_FY19] + [NYC_HC_FY19] + [NYC_SC_FY19] + [ORL_HC_FY19] + [ORL_SC_FY19] + [PHI_HC_FY19] + [PHI_SC_FY19] + [RI_HC_FY19] + [RI_SC_FY19] + [SAC_HC_FY19] + [SAC_SC_FY19] + [SA_HC_FY19] + [SA_SC_FY19] + [SJ_HC_FY19] + [SJ_SC_FY19] + [SEA_HC_FY19] + [SEA_SC_FY19] + [TUL_HC_FY19] + [TUL_SC_FY19] + [WASH_HC_FY19] + [WASH_SC_FY19] + [DAL_HC_FY19] + [DAL_SC_FY19]

	update ODW.Recent_History.DimRecentGivingFY20
	set TOTAL_FY20 = [BR_HC_FY20] + [BR_SC_FY20] + [BOS_HC_FY20] + [BOS_SC_FY20] + [CF_HC_FY20] + [CF_SC_FY20] + [CHI_HC_FY20] + [CHI_SC_FY20] + [CLE_HC_FY20] + [CLE_SC_FY20] + [CIA_HC_FY20] + [CIA_SC_FY20] + [CUS_HC_FY20] + [CUS_SC_FY20] + [DEN_HC_FY20] + [DEN_SC_FY20] + [DET_HC_FY20] + [DET_SC_FY20] + [HQ_HC_FY20] + [HQ_SC_FY20] + [JAX_HC_FY20] + [JAX_SC_FY20] + [LR_HC_FY20] + [LR_SC_FY20] + [LA_HC_FY20] + [LA_SC_FY20] + [LOU_HC_FY20] + [LOU_SC_FY20] + [MIA_HC_FY20] + [MIA_SC_FY20] + [MIL_HC_FY20] + [MIL_SC_FY20] + [NH_HC_FY20] + [NH_SC_FY20] + [NO_HC_FY20] + [NO_SC_FY20] + [NYC_HC_FY20] + [NYC_SC_FY20] + [ORL_HC_FY20] + [ORL_SC_FY20] + [PHI_HC_FY20] + [PHI_SC_FY20] + [RI_HC_FY20] + [RI_SC_FY20] + [SAC_HC_FY20] + [SAC_SC_FY20] + [SA_HC_FY20] + [SA_SC_FY20] + [SJ_HC_FY20] + [SJ_SC_FY20] + [SEA_HC_FY20] + [SEA_SC_FY20] + [TUL_HC_FY20] + [TUL_SC_FY20] + [WASH_HC_FY20] + [WASH_SC_FY20] + [DAL_HC_FY20] + [DAL_SC_FY20]

	update ODW.Recent_History.DimTotalGiving
	set TOTAL = [BR_HC_Total] + [BR_SC_Total] + [BOS_HC_Total] + [BOS_SC_Total] + [CF_HC_Total] + [CF_SC_Total] + [CHI_HC_Total] + [CHI_SC_Total] + [CLE_HC_Total] + [CLE_SC_Total] + [CIA_HC_Total] + [CIA_SC_Total] + [CUS_HC_Total] + [CUS_SC_Total] + [DEN_HC_Total] + [DEN_SC_Total] + [DET_HC_Total] + [DET_SC_Total] + [HQ_HC_Total] + [HQ_SC_Total] + [JAX_HC_Total] + [JAX_SC_Total] + [LR_HC_Total] + [LR_SC_Total] + [LA_HC_Total] + [LA_SC_Total] + [LOU_HC_Total] + [LOU_SC_Total] + [MIA_HC_Total] + [MIA_SC_Total] + [MIL_HC_Total] + [MIL_SC_Total] + [NH_HC_Total] + [NH_SC_Total] + [NO_HC_Total] + [NO_SC_Total] + [NYC_HC_Total] + [NYC_SC_Total] + [ORL_HC_Total] + [ORL_SC_Total] + [PHI_HC_Total] + [PHI_SC_Total] + [RI_HC_Total] + [RI_SC_Total] + [SAC_HC_Total] + [SAC_SC_Total] + [SA_HC_Total] + [SA_SC_Total] + [SJ_HC_Total] + [SJ_SC_Total] + [SEA_HC_Total] + [SEA_SC_Total] + [TUL_HC_Total] + [TUL_SC_Total] + [WASH_HC_Total] + [WASH_SC_Total] + [DAL_HC_TOTAL] + [DAL_SC_TOTAL]

	update ODW.dbo.DimContactRelationship set Category = 'N/A' where Category is null
	update ODW.dbo.DimContactRelationship set [Full Name From] = 'N/A' where [Full Name From] is null
	update ODW.dbo.DimContactRelationship set [Full Name To] = 'N/A' where [Full Name To] is null
	update ODW.dbo.DimContactRelationship set [Account Name no Household From] = 'N/A' where [Account Name no Household From] is null
	update ODW.dbo.DimContactRelationship set [Account Name no Household To] = 'N/A' where [Account Name no Household To] is null

	select a.*, case when ContactRelationshipID < CRID then CRID else ContactRelationshipID end ID_To_Delete
	into #Temp
	from ODW.dbo.Relationship_Dupes (nolock) a

	delete from ODW.dbo.DimContactRelationship where ContactRelationshipID in (select distinct ID_To_Delete from #Temp)

	update ODW.Recent_History.DimRecentGivingFY05
	set TOTAL_SOFT_FY05 = BR_SC_FY05 + BOS_SC_FY05 + CF_SC_FY05 + CHI_SC_FY05 + CLE_SC_FY05 + CIA_SC_FY05 + CUS_SC_FY05 + 
	DEN_SC_FY05 + DET_SC_FY05 + HQ_SC_FY05 + JAX_SC_FY05 + LR_SC_FY05 + LA_SC_FY05 + LOU_SC_FY05 + MIA_SC_FY05 + 
	MIL_SC_FY05 + NH_SC_FY05 + NO_SC_FY05 + NYC_SC_FY05 + ORL_SC_FY05 + PHI_SC_FY05 + RI_SC_FY05 + SAC_SC_FY05 + 
	SA_SC_FY05 + SJ_SC_FY05 + SEA_SC_FY05 + TUL_SC_FY05 + WASH_SC_FY05 

	update ODW.Recent_History.DimRecentGivingFY05
	set TOTAL_HARD_FY05 = BR_HC_FY05 + BOS_HC_FY05 + CF_HC_FY05 + CHI_HC_FY05 + CLE_HC_FY05 + CIA_HC_FY05 + CUS_HC_FY05 + 
	DEN_HC_FY05 + DET_HC_FY05 + HQ_HC_FY05 + JAX_HC_FY05 + LR_HC_FY05 + LA_HC_FY05 + LOU_HC_FY05 + MIA_HC_FY05 + 
	MIL_HC_FY05 + NH_HC_FY05 + NO_HC_FY05 + NYC_HC_FY05 + ORL_HC_FY05 + PHI_HC_FY05 + RI_HC_FY05 + SAC_HC_FY05 + 
	SA_HC_FY05 + SJ_HC_FY05 + SEA_HC_FY05 + TUL_HC_FY05 + WASH_HC_FY05 

	update ODW.Recent_History.DimRecentGivingFY06
	set TOTAL_SOFT_FY06 = BR_SC_FY06 + BOS_SC_FY06 + CF_SC_FY06 + CHI_SC_FY06 + CLE_SC_FY06 + CIA_SC_FY06 + CUS_SC_FY06 + 
	DEN_SC_FY06 + DET_SC_FY06 + HQ_SC_FY06 + JAX_SC_FY06 + LR_SC_FY06 + LA_SC_FY06 + LOU_SC_FY06 + MIA_SC_FY06 + 
	MIL_SC_FY06 + NH_SC_FY06 + NO_SC_FY06 + NYC_SC_FY06 + ORL_SC_FY06 + PHI_SC_FY06 + RI_SC_FY06 + SAC_SC_FY06 + 
	SA_SC_FY06 + SJ_SC_FY06 + SEA_SC_FY06 + TUL_SC_FY06 + WASH_SC_FY06  

	update ODW.Recent_History.DimRecentGivingFY06
	set TOTAL_HARD_FY06 = BR_HC_FY06 + BOS_HC_FY06 + CF_HC_FY06 + CHI_HC_FY06 + CLE_HC_FY06 + CIA_HC_FY06 + CUS_HC_FY06 + 
	DEN_HC_FY06 + DET_HC_FY06 + HQ_HC_FY06 + JAX_HC_FY06 + LR_HC_FY06 + LA_HC_FY06 + LOU_HC_FY06 + MIA_HC_FY06 + 
	MIL_HC_FY06 + NH_HC_FY06 + NO_HC_FY06 + NYC_HC_FY06 + ORL_HC_FY06 + PHI_HC_FY06 + RI_HC_FY06 + SAC_HC_FY06 + 
	SA_HC_FY06 + SJ_HC_FY06 + SEA_HC_FY06 + TUL_HC_FY06 + WASH_HC_FY06 

	update ODW.Recent_History.DimRecentGivingFY07
	set TOTAL_SOFT_FY07 = BR_SC_FY07 + BOS_SC_FY07 + CF_SC_FY07 + CHI_SC_FY07 + CLE_SC_FY07 + CIA_SC_FY07 + CUS_SC_FY07 + 
	DEN_SC_FY07 + DET_SC_FY07 + HQ_SC_FY07 + JAX_SC_FY07 + LR_SC_FY07 + LA_SC_FY07 + LOU_SC_FY07 + MIA_SC_FY07 + 
	MIL_SC_FY07 + NH_SC_FY07 + NO_SC_FY07 + NYC_SC_FY07 + ORL_SC_FY07 + PHI_SC_FY07 + RI_SC_FY07 + SAC_SC_FY07 + 
	SA_SC_FY07 + SJ_SC_FY07 + SEA_SC_FY07 + TUL_SC_FY07 + WASH_SC_FY07 

	update ODW.Recent_History.DimRecentGivingFY07
	set TOTAL_HARD_FY07 = BR_HC_FY07 + BOS_HC_FY07 + CF_HC_FY07 + CHI_HC_FY07 + CLE_HC_FY07 + CIA_HC_FY07 + CUS_HC_FY07 + 
	DEN_HC_FY07 + DET_HC_FY07 + HQ_HC_FY07 + JAX_HC_FY07 + LR_HC_FY07 + LA_HC_FY07 + LOU_HC_FY07 + MIA_HC_FY07 + 
	MIL_HC_FY07 + NH_HC_FY07 + NO_HC_FY07 + NYC_HC_FY07 + ORL_HC_FY07 + PHI_HC_FY07 + RI_HC_FY07 + SAC_HC_FY07 + 
	SA_HC_FY07 + SJ_HC_FY07 + SEA_HC_FY07 + TUL_HC_FY07 + WASH_HC_FY07 

	update ODW.Recent_History.DimRecentGivingFY08
	set TOTAL_SOFT_FY08 = BR_SC_FY08 + BOS_SC_FY08 + CF_SC_FY08 + CHI_SC_FY08 + CLE_SC_FY08 + CIA_SC_FY08 + CUS_SC_FY08 + 
	DEN_SC_FY08 + DET_SC_FY08 + HQ_SC_FY08 + JAX_SC_FY08 + LR_SC_FY08 + LA_SC_FY08 + LOU_SC_FY08 + MIA_SC_FY08 + 
	MIL_SC_FY08 + NH_SC_FY08 + NO_SC_FY08 + NYC_SC_FY08 + ORL_SC_FY08 + PHI_SC_FY08 + RI_SC_FY08 + SAC_SC_FY08 + 
	SA_SC_FY08 + SJ_SC_FY08 + SEA_SC_FY08 + TUL_SC_FY08 + WASH_SC_FY08 

	update ODW.Recent_History.DimRecentGivingFY08
	set TOTAL_HARD_FY08 = BR_HC_FY08 + BOS_HC_FY08 + CF_HC_FY08 + CHI_HC_FY08 + CLE_HC_FY08 + CIA_HC_FY08 + CUS_HC_FY08 + 
	DEN_HC_FY08 + DET_HC_FY08 + HQ_HC_FY08 + JAX_HC_FY08 + LR_HC_FY08 + LA_HC_FY08 + LOU_HC_FY08 + MIA_HC_FY08 + 
	MIL_HC_FY08 + NH_HC_FY08 + NO_HC_FY08 + NYC_HC_FY08 + ORL_HC_FY08 + PHI_HC_FY08 + RI_HC_FY08 + SAC_HC_FY08 + 
	SA_HC_FY08 + SJ_HC_FY08 + SEA_HC_FY08 + TUL_HC_FY08 + WASH_HC_FY08 


	update ODW.Recent_History.DimRecentGivingFY09
	set TOTAL_SOFT_FY09 = BR_SC_FY09 + BOS_SC_FY09 + CF_SC_FY09 + CHI_SC_FY09 + CLE_SC_FY09 + CIA_SC_FY09 + CUS_SC_FY09 + 
	DEN_SC_FY09 + DET_SC_FY09 + HQ_SC_FY09 + JAX_SC_FY09 + LR_SC_FY09 + LA_SC_FY09 + LOU_SC_FY09 + MIA_SC_FY09 + 
	MIL_SC_FY09 + NH_SC_FY09 + NO_SC_FY09 + NYC_SC_FY09 + ORL_SC_FY09 + PHI_SC_FY09 + RI_SC_FY09 + SAC_SC_FY09 + 
	SA_SC_FY09 + SJ_SC_FY09 + SEA_SC_FY09 + TUL_SC_FY09 + WASH_SC_FY09

	update ODW.Recent_History.DimRecentGivingFY09
	set TOTAL_HARD_FY09 = BR_HC_FY09 + BOS_HC_FY09 + CF_HC_FY09 + CHI_HC_FY09 + CLE_HC_FY09 + CIA_HC_FY09 + CUS_HC_FY09 + 
	DEN_HC_FY09 + DET_HC_FY09 + HQ_HC_FY09 + JAX_HC_FY09 + LR_HC_FY09 + LA_HC_FY09 + LOU_HC_FY09 + MIA_HC_FY09 + 
	MIL_HC_FY09 + NH_HC_FY09 + NO_HC_FY09 + NYC_HC_FY09 + ORL_HC_FY09 + PHI_HC_FY09 + RI_HC_FY09 + SAC_HC_FY09 + 
	SA_HC_FY09 + SJ_HC_FY09 + SEA_HC_FY09 + TUL_HC_FY09 + WASH_HC_FY09 


	update ODW.Recent_History.DimRecentGivingFY10
	set TOTAL_SOFT_FY10 = BR_SC_FY10 + BOS_SC_FY10 + CF_SC_FY10 + CHI_SC_FY10 + CLE_SC_FY10 + CIA_SC_FY10 + CUS_SC_FY10 + 
	DEN_SC_FY10 + DET_SC_FY10 + HQ_SC_FY10 + JAX_SC_FY10 + LR_SC_FY10 + LA_SC_FY10 + LOU_SC_FY10 + MIA_SC_FY10 + 
	MIL_SC_FY10 + NH_SC_FY10 + NO_SC_FY10 + NYC_SC_FY10 + ORL_SC_FY10 + PHI_SC_FY10 + RI_SC_FY10 + SAC_SC_FY10 + 
	SA_SC_FY10 + SJ_SC_FY10 + SEA_SC_FY10 + TUL_SC_FY10 + WASH_SC_FY10

	update ODW.Recent_History.DimRecentGivingFY10
	set TOTAL_HARD_FY10 = BR_HC_FY10 + BOS_HC_FY10 + CF_HC_FY10 + CHI_HC_FY10 + CLE_HC_FY10 + CIA_HC_FY10 + CUS_HC_FY10 + 
	DEN_HC_FY10 + DET_HC_FY10 + HQ_HC_FY10 + JAX_HC_FY10 + LR_HC_FY10 + LA_HC_FY10 + LOU_HC_FY10 + MIA_HC_FY10 + 
	MIL_HC_FY10 + NH_HC_FY10 + NO_HC_FY10 + NYC_HC_FY10 + ORL_HC_FY10 + PHI_HC_FY10 + RI_HC_FY10 + SAC_HC_FY10 + 
	SA_HC_FY10 + SJ_HC_FY10 + SEA_HC_FY10 + TUL_HC_FY10 + WASH_HC_FY10 

	update ODW.Recent_History.DimRecentGivingFY11
	set TOTAL_SOFT_FY11 = BR_SC_FY11 + BOS_SC_FY11 + CF_SC_FY11 + CHI_SC_FY11 + CLE_SC_FY11 + CIA_SC_FY11 + CUS_SC_FY11 + 
	DEN_SC_FY11 + DET_SC_FY11 + HQ_SC_FY11 + JAX_SC_FY11 + LR_SC_FY11 + LA_SC_FY11 + LOU_SC_FY11 + MIA_SC_FY11 + 
	MIL_SC_FY11 + NH_SC_FY11 + NO_SC_FY11 + NYC_SC_FY11 + ORL_SC_FY11 + PHI_SC_FY11 + RI_SC_FY11 + SAC_SC_FY11 + 
	SA_SC_FY11 + SJ_SC_FY11 + SEA_SC_FY11 + TUL_SC_FY11 + WASH_SC_FY11 

	update ODW.Recent_History.DimRecentGivingFY11
	set TOTAL_HARD_FY11 = BR_HC_FY11 + BOS_HC_FY11 + CF_HC_FY11 + CHI_HC_FY11 + CLE_HC_FY11 + CIA_HC_FY11 + CUS_HC_FY11 + 
	DEN_HC_FY11 + DET_HC_FY11 + HQ_HC_FY11 + JAX_HC_FY11 + LR_HC_FY11 + LA_HC_FY11 + LOU_HC_FY11 + MIA_HC_FY11 + 
	MIL_HC_FY11 + NH_HC_FY11 + NO_HC_FY11 + NYC_HC_FY11 + ORL_HC_FY11 + PHI_HC_FY11 + RI_HC_FY11 + SAC_HC_FY11 + 
	SA_HC_FY11 + SJ_HC_FY11 + SEA_HC_FY11 + TUL_HC_FY11 + WASH_HC_FY11 

	update ODW.Recent_History.DimRecentGivingFY12
	set TOTAL_SOFT_FY12 = BR_SC_FY12 + BOS_SC_FY12 + CF_SC_FY12 + CHI_SC_FY12 + CLE_SC_FY12 + CIA_SC_FY12 + CUS_SC_FY12 + 
	DEN_SC_FY12 + DET_SC_FY12 + HQ_SC_FY12 + JAX_SC_FY12 + LR_SC_FY12 + LA_SC_FY12 + LOU_SC_FY12 + MIA_SC_FY12 + 
	MIL_SC_FY12 + NH_SC_FY12 + NO_SC_FY12 + NYC_SC_FY12 + ORL_SC_FY12 + PHI_SC_FY12 + RI_SC_FY12 + SAC_SC_FY12 + 
	SA_SC_FY12 + SJ_SC_FY12 + SEA_SC_FY12 + TUL_SC_FY12 + WASH_SC_FY12 

	update ODW.Recent_History.DimRecentGivingFY12
	set TOTAL_HARD_FY12 = BR_HC_FY12 + BOS_HC_FY12 + CF_HC_FY12 + CHI_HC_FY12 + CLE_HC_FY12 + CIA_HC_FY12 + CUS_HC_FY12 + 
	DEN_HC_FY12 + DET_HC_FY12 + HQ_HC_FY12 + JAX_HC_FY12 + LR_HC_FY12 + LA_HC_FY12 + LOU_HC_FY12 + MIA_HC_FY12 + 
	MIL_HC_FY12 + NH_HC_FY12 + NO_HC_FY12 + NYC_HC_FY12 + ORL_HC_FY12 + PHI_HC_FY12 + RI_HC_FY12 + SAC_HC_FY12 + 
	SA_HC_FY12 + SJ_HC_FY12 + SEA_HC_FY12 + TUL_HC_FY12 + WASH_HC_FY12 


	update ODW.Recent_History.DimRecentGivingFY13
	set TOTAL_SOFT_FY13 = BR_SC_FY13 + BOS_SC_FY13 + CF_SC_FY13 + CHI_SC_FY13 + CLE_SC_FY13 + CIA_SC_FY13 + CUS_SC_FY13 + 
	DEN_SC_FY13 + DET_SC_FY13 + HQ_SC_FY13 + JAX_SC_FY13 + LR_SC_FY13 + LA_SC_FY13 + LOU_SC_FY13 + MIA_SC_FY13 + 
	MIL_SC_FY13 + NH_SC_FY13 + NO_SC_FY13 + NYC_SC_FY13 + ORL_SC_FY13 + PHI_SC_FY13 + RI_SC_FY13 + SAC_SC_FY13 + 
	SA_SC_FY13 + SJ_SC_FY13 + SEA_SC_FY13 + TUL_SC_FY13 + WASH_SC_FY13 

	update ODW.Recent_History.DimRecentGivingFY13
	set TOTAL_HARD_FY13 = BR_HC_FY13 + BOS_HC_FY13 + CF_HC_FY13 + CHI_HC_FY13 + CLE_HC_FY13 + CIA_HC_FY13 + CUS_HC_FY13 + 
	DEN_HC_FY13 + DET_HC_FY13 + HQ_HC_FY13 + JAX_HC_FY13 + LR_HC_FY13 + LA_HC_FY13 + LOU_HC_FY13 + MIA_HC_FY13 + 
	MIL_HC_FY13 + NH_HC_FY13 + NO_HC_FY13 + NYC_HC_FY13 + ORL_HC_FY13 + PHI_HC_FY13 + RI_HC_FY13 + SAC_HC_FY13 + 
	SA_HC_FY13 + SJ_HC_FY13 + SEA_HC_FY13 + TUL_HC_FY13 + WASH_HC_FY13 


	update ODW.Recent_History.DimRecentGivingFY14
	set TOTAL_SOFT_FY14 = BR_SC_FY14 + BOS_SC_FY14 + CF_SC_FY14 + CHI_SC_FY14 + CLE_SC_FY14 + CIA_SC_FY14 + CUS_SC_FY14 + 
	DEN_SC_FY14 + DET_SC_FY14 + HQ_SC_FY14 + JAX_SC_FY14 + LR_SC_FY14 + LA_SC_FY14 + LOU_SC_FY14 + MIA_SC_FY14 + 
	MIL_SC_FY14 + NH_SC_FY14 + NO_SC_FY14 + NYC_SC_FY14 + ORL_SC_FY14 + PHI_SC_FY14 + RI_SC_FY14 + SAC_SC_FY14 + 
	SA_SC_FY14 + SJ_SC_FY14 + SEA_SC_FY14 + TUL_SC_FY14 + WASH_SC_FY14 

	update ODW.Recent_History.DimRecentGivingFY14
	set TOTAL_HARD_FY14 = BR_HC_FY14 + BOS_HC_FY14 + CF_HC_FY14 + CHI_HC_FY14 + CLE_HC_FY14 + CIA_HC_FY14 + CUS_HC_FY14 + 
	DEN_HC_FY14 + DET_HC_FY14 + HQ_HC_FY14 + JAX_HC_FY14 + LR_HC_FY14 + LA_HC_FY14 + LOU_HC_FY14 + MIA_HC_FY14 + 
	MIL_HC_FY14 + NH_HC_FY14 + NO_HC_FY14 + NYC_HC_FY14 + ORL_HC_FY14 + PHI_HC_FY14 + RI_HC_FY14 + SAC_HC_FY14 + 
	SA_HC_FY14 + SJ_HC_FY14 + SEA_HC_FY14 + TUL_HC_FY14 + WASH_HC_FY14 

	update ODW.Recent_History.DimRecentGivingFY15
	set TOTAL_SOFT_FY15 = BR_SC_FY15 + BOS_SC_FY15 + CF_SC_FY15 + CHI_SC_FY15 + CLE_SC_FY15 + CIA_SC_FY15 + CUS_SC_FY15 + 
	DEN_SC_FY15 + DET_SC_FY15 + HQ_SC_FY15 + JAX_SC_FY15 + LR_SC_FY15 + LA_SC_FY15 + LOU_SC_FY15 + MIA_SC_FY15 + 
	MIL_SC_FY15 + NH_SC_FY15 + NO_SC_FY15 + NYC_SC_FY15 + ORL_SC_FY15 + PHI_SC_FY15 + RI_SC_FY15 + SAC_SC_FY15 + 
	SA_SC_FY15 + SJ_SC_FY15 + SEA_SC_FY15 + TUL_SC_FY15 + WASH_SC_FY15 + DAL_SC_FY15

	update ODW.Recent_History.DimRecentGivingFY15
	set TOTAL_HARD_FY15 = BR_HC_FY15 + BOS_HC_FY15 + CF_HC_FY15 + CHI_HC_FY15 + CLE_HC_FY15 + CIA_HC_FY15 + CUS_HC_FY15 + 
	DEN_HC_FY15 + DET_HC_FY15 + HQ_HC_FY15 + JAX_HC_FY15 + LR_HC_FY15 + LA_HC_FY15 + LOU_HC_FY15 + MIA_HC_FY15 + 
	MIL_HC_FY15 + NH_HC_FY15 + NO_HC_FY15 + NYC_HC_FY15 + ORL_HC_FY15 + PHI_HC_FY15 + RI_HC_FY15 + SAC_HC_FY15 + 
	SA_HC_FY15 + SJ_HC_FY15 + SEA_HC_FY15 + TUL_HC_FY15 + WASH_HC_FY15 + DAL_HC_FY15

	update ODW.Recent_History.DimRecentGivingFY16
	set TOTAL_SOFT_FY16 = BR_SC_FY16 + BOS_SC_FY16 + CF_SC_FY16 + CHI_SC_FY16 + CLE_SC_FY16 + CIA_SC_FY16 + CUS_SC_FY16 + 
	DEN_SC_FY16 + DET_SC_FY16 + HQ_SC_FY16 + JAX_SC_FY16 + LR_SC_FY16 + LA_SC_FY16 + LOU_SC_FY16 + MIA_SC_FY16 + 
	MIL_SC_FY16 + NH_SC_FY16 + NO_SC_FY16 + NYC_SC_FY16 + ORL_SC_FY16 + PHI_SC_FY16 + RI_SC_FY16 + SAC_SC_FY16 + 
	SA_SC_FY16 + SJ_SC_FY16 + SEA_SC_FY16 + TUL_SC_FY16 + WASH_SC_FY16 + DAL_SC_FY16

	update ODW.Recent_History.DimRecentGivingFY16
	set TOTAL_HARD_FY16 = BR_HC_FY16 + BOS_HC_FY16 + CF_HC_FY16 + CHI_HC_FY16 + CLE_HC_FY16 + CIA_HC_FY16 + CUS_HC_FY16 + 
	DEN_HC_FY16 + DET_HC_FY16 + HQ_HC_FY16 + JAX_HC_FY16 + LR_HC_FY16 + LA_HC_FY16 + LOU_HC_FY16 + MIA_HC_FY16 + 
	MIL_HC_FY16 + NH_HC_FY16 + NO_HC_FY16 + NYC_HC_FY16 + ORL_HC_FY16 + PHI_HC_FY16 + RI_HC_FY16 + SAC_HC_FY16 + 
	SA_HC_FY16 + SJ_HC_FY16 + SEA_HC_FY16 + TUL_HC_FY16 + WASH_HC_FY16 + DAL_HC_FY16

	update ODW.Recent_History.DimRecentGivingFY17
	set TOTAL_SOFT_FY17 = BR_SC_FY17 + BOS_SC_FY17 + CF_SC_FY17 + CHI_SC_FY17 + CLE_SC_FY17 + CIA_SC_FY17 + CUS_SC_FY17 + 
	DEN_SC_FY17 + DET_SC_FY17 + HQ_SC_FY17 + JAX_SC_FY17 + LR_SC_FY17 + LA_SC_FY17 + LOU_SC_FY17 + MIA_SC_FY17 + 
	MIL_SC_FY17 + NH_SC_FY17 + NO_SC_FY17 + NYC_SC_FY17 + ORL_SC_FY17 + PHI_SC_FY17 + RI_SC_FY17 + SAC_SC_FY17 + 
	SA_SC_FY17 + SJ_SC_FY17 + SEA_SC_FY17 + TUL_SC_FY17 + WASH_SC_FY17 + DAL_SC_FY17

	update ODW.Recent_History.DimRecentGivingFY17
	set TOTAL_HARD_FY17 = BR_HC_FY17 + BOS_HC_FY17 + CF_HC_FY17 + CHI_HC_FY17 + CLE_HC_FY17 + CIA_HC_FY17 + CUS_HC_FY17 + 
	DEN_HC_FY17 + DET_HC_FY17 + HQ_HC_FY17 + JAX_HC_FY17 + LR_HC_FY17 + LA_HC_FY17 + LOU_HC_FY17 + MIA_HC_FY17 + 
	MIL_HC_FY17 + NH_HC_FY17 + NO_HC_FY17 + NYC_HC_FY17 + ORL_HC_FY17 + PHI_HC_FY17 + RI_HC_FY17 + SAC_HC_FY17 + 
	SA_HC_FY17 + SJ_HC_FY17 + SEA_HC_FY17 + TUL_HC_FY17 + WASH_HC_FY17 + DAL_HC_FY17

	update ODW.Recent_History.DimRecentGivingFY18
	set TOTAL_SOFT_FY18 = BR_SC_FY18 + BOS_SC_FY18 + CF_SC_FY18 + CHI_SC_FY18 + CLE_SC_FY18 + CIA_SC_FY18 + CUS_SC_FY18 + 
	DEN_SC_FY18 + DET_SC_FY18 + HQ_SC_FY18 + JAX_SC_FY18 + LR_SC_FY18 + LA_SC_FY18 + LOU_SC_FY18 + MIA_SC_FY18 + 
	MIL_SC_FY18 + NH_SC_FY18 + NO_SC_FY18 + NYC_SC_FY18 + ORL_SC_FY18 + PHI_SC_FY18 + RI_SC_FY18 + SAC_SC_FY18 + 
	SA_SC_FY18 + SJ_SC_FY18 + SEA_SC_FY18 + TUL_SC_FY18 + WASH_SC_FY18 + DAL_SC_FY18

	update ODW.Recent_History.DimRecentGivingFY18
	set TOTAL_HARD_FY18 = BR_HC_FY18 + BOS_HC_FY18 + CF_HC_FY18 + CHI_HC_FY18 + CLE_HC_FY18 + CIA_HC_FY18 + CUS_HC_FY18 + 
	DEN_HC_FY18 + DET_HC_FY18 + HQ_HC_FY18 + JAX_HC_FY18 + LR_HC_FY18 + LA_HC_FY18 + LOU_HC_FY18 + MIA_HC_FY18 + 
	MIL_HC_FY18 + NH_HC_FY18 + NO_HC_FY18 + NYC_HC_FY18 + ORL_HC_FY18 + PHI_HC_FY18 + RI_HC_FY18 + SAC_HC_FY18 + 
	SA_HC_FY18 + SJ_HC_FY18 + SEA_HC_FY18 + TUL_HC_FY18 + WASH_HC_FY18 + DAL_HC_FY18

	update ODW.Recent_History.DimRecentGivingFY19
	set TOTAL_SOFT_FY19 = BR_SC_FY19 + BOS_SC_FY19 + CF_SC_FY19 + CHI_SC_FY19 + CLE_SC_FY19 + CIA_SC_FY19 + CUS_SC_FY19 + 
	DEN_SC_FY19 + DET_SC_FY19 + HQ_SC_FY19 + JAX_SC_FY19 + LR_SC_FY19 + LA_SC_FY19 + LOU_SC_FY19 + MIA_SC_FY19 + 
	MIL_SC_FY19 + NH_SC_FY19 + NO_SC_FY19 + NYC_SC_FY19 + ORL_SC_FY19 + PHI_SC_FY19 + RI_SC_FY19 + SAC_SC_FY19 + 
	SA_SC_FY19 + SJ_SC_FY19 + SEA_SC_FY19 + TUL_SC_FY19 + WASH_SC_FY19 + DAL_SC_FY19

	update ODW.Recent_History.DimRecentGivingFY19
	set TOTAL_HARD_FY19 = BR_HC_FY19 + BOS_HC_FY19 + CF_HC_FY19 + CHI_HC_FY19 + CLE_HC_FY19 + CIA_HC_FY19 + CUS_HC_FY19 + 
	DEN_HC_FY19 + DET_HC_FY19 + HQ_HC_FY19 + JAX_HC_FY19 + LR_HC_FY19 + LA_HC_FY19 + LOU_HC_FY19 + MIA_HC_FY19 + 
	MIL_HC_FY19 + NH_HC_FY19 + NO_HC_FY19 + NYC_HC_FY19 + ORL_HC_FY19 + PHI_HC_FY19 + RI_HC_FY19 + SAC_HC_FY19 + 
	SA_HC_FY19 + SJ_HC_FY19 + SEA_HC_FY19 + TUL_HC_FY19 + WASH_HC_FY19 + DAL_HC_FY19

	update ODW.Recent_History.DimRecentGivingFY20
	set TOTAL_SOFT_FY20 = BR_SC_FY20 + BOS_SC_FY20 + CF_SC_FY20 + CHI_SC_FY20 + CLE_SC_FY20 + CIA_SC_FY20 + CUS_SC_FY20 + 
	DEN_SC_FY20 + DET_SC_FY20 + HQ_SC_FY20 + JAX_SC_FY20 + LR_SC_FY20 + LA_SC_FY20 + LOU_SC_FY20 + MIA_SC_FY20 + 
	MIL_SC_FY20 + NH_SC_FY20 + NO_SC_FY20 + NYC_SC_FY20 + ORL_SC_FY20 + PHI_SC_FY20 + RI_SC_FY20 + SAC_SC_FY20 + 
	SA_SC_FY20 + SJ_SC_FY20 + SEA_SC_FY20 + TUL_SC_FY20 + WASH_SC_FY20 + DAL_SC_FY20

	update ODW.Recent_History.DimRecentGivingFY20
	set TOTAL_HARD_FY20 = BR_HC_FY20 + BOS_HC_FY20 + CF_HC_FY20 + CHI_HC_FY20 + CLE_HC_FY20 + CIA_HC_FY20 + CUS_HC_FY20 + 
	DEN_HC_FY20 + DET_HC_FY20 + HQ_HC_FY20 + JAX_HC_FY20 + LR_HC_FY20 + LA_HC_FY20 + LOU_HC_FY20 + MIA_HC_FY20 + 
	MIL_HC_FY20 + NH_HC_FY20 + NO_HC_FY20 + NYC_HC_FY20 + ORL_HC_FY20 + PHI_HC_FY20 + RI_HC_FY20 + SAC_HC_FY20 + 
	SA_HC_FY20 + SJ_HC_FY20 + SEA_HC_FY20 + TUL_HC_FY20 + WASH_HC_FY20 + DAL_HC_FY20

	update ODW.Recent_History.DimTotalGiving
	set TOTAL_SOFT = BR_SC_Total + BOS_SC_Total + CF_SC_Total + CHI_SC_Total + CLE_SC_Total + CIA_SC_Total + CUS_SC_Total + 
	DEN_SC_Total + DET_SC_Total + HQ_SC_Total + JAX_SC_Total + LR_SC_Total + LA_SC_Total + LOU_SC_Total + MIA_SC_Total + 
	MIL_SC_Total + NH_SC_Total + NO_SC_Total + NYC_SC_Total + ORL_SC_Total + PHI_SC_Total + RI_SC_Total + SAC_SC_Total + 
	SA_SC_Total + SJ_SC_Total + SEA_SC_Total + TUL_SC_Total + WASH_SC_Total + DAL_SC_TOTAL

	update ODW.Recent_History.DimTotalGiving
	set TOTAL_HARD = BR_HC_Total + BOS_HC_Total + CF_HC_Total + CHI_HC_Total + CLE_HC_Total + CIA_HC_Total + CUS_HC_Total + 
	DEN_HC_Total + DET_HC_Total + HQ_HC_Total + JAX_HC_Total + LR_HC_Total + LA_HC_Total + LOU_HC_Total + MIA_HC_Total + 
	MIL_HC_Total + NH_HC_Total + NO_HC_Total + NYC_HC_Total + ORL_HC_Total + PHI_HC_Total + RI_HC_Total + SAC_HC_Total + 
	SA_HC_Total + SJ_HC_Total + SEA_HC_Total + TUL_HC_Total + WASH_HC_Total + DAL_HC_TOTAL

	update ODW.Recent_History.DimRecentGivingFY10 set GaveVia_FY10 = 0
	update ODW.Recent_History.DimRecentGivingFY11 set GaveVia_FY11 = 0
	update ODW.Recent_History.DimRecentGivingFY12 set GaveVia_FY12 = 0
	update ODW.Recent_History.DimRecentGivingFY13 set GaveVia_FY13 = 0
	update ODW.Recent_History.DimRecentGivingFY14 set GaveVia_FY14 = 0
	update ODW.Recent_History.DimRecentGivingFY15 set GaveVia_FY15 = 0
	update ODW.Recent_History.DimRecentGivingFY16 set GaveVia_FY16 = 0
	update ODW.Recent_History.DimRecentGivingFY17 set GaveVia_FY17 = 0
	update ODW.Recent_History.DimRecentGivingFY18 set GaveVia_FY18 = 0
	update ODW.Recent_History.DimRecentGivingFY19 set GaveVia_FY19 = 0
	update ODW.Recent_History.DimRecentGivingFY20 set GaveVia_FY20 = 0

	select b.AccountID HC_Account, d.AccountID SC_Account, c.[General Accounting Unit Name] BusinessUnit, 
	c.[Fiscal Year], sum(c.[Amount]) Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #Soft_Randomizer
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	group by b.AccountID, d.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]
	order by [Fiscal Year]

	create table #Randomizer
	(	[RandomID] [int] IDENTITY(1,1) NOT NULL,
		[HC_Account] [int] NULL,
		[SC_Account] [int] NULL,
		[Fiscal Year] [varchar] (256))

	insert into #Randomizer(HC_Account, SC_Account, [Fiscal Year])
	select distinct HC_Account, SC_Account, [Fiscal Year] from #Soft_Randomizer order by [Fiscal Year], HC_Account, SC_Account

	update ODW.Recent_History.DimRecentGivingFY10 Set GaveVia_FY10 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY10 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY10'

	update ODW.Recent_History.DimRecentGivingFY10 Set GaveVia_FY10 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY10 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY10'

	update ODW.Recent_History.DimRecentGivingFY11 Set GaveVia_FY11 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY11 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY11'

	update ODW.Recent_History.DimRecentGivingFY11 Set GaveVia_FY11 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY11 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY11'

	update ODW.Recent_History.DimRecentGivingFY12 Set GaveVia_FY12 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY12 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY12'

	update ODW.Recent_History.DimRecentGivingFY12 Set GaveVia_FY12 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY12 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY12'

	update ODW.Recent_History.DimRecentGivingFY13 Set GaveVia_FY13 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY13 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY13'

	update ODW.Recent_History.DimRecentGivingFY13 Set GaveVia_FY13 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY13 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY13'

	update ODW.Recent_History.DimRecentGivingFY14 Set GaveVia_FY14 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY14 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY14'

	update ODW.Recent_History.DimRecentGivingFY14 Set GaveVia_FY14 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY14 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY14'

	update ODW.Recent_History.DimRecentGivingFY15 Set GaveVia_FY15 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY15 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY15'

	update ODW.Recent_History.DimRecentGivingFY15 Set GaveVia_FY15 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY15 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY15'

	update ODW.Recent_History.DimRecentGivingFY16 Set GaveVia_FY16 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY16 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY16'

	update ODW.Recent_History.DimRecentGivingFY16 Set GaveVia_FY16 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY16 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY16'

	update ODW.Recent_History.DimRecentGivingFY17 Set GaveVia_FY17 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY17 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY17'

	update ODW.Recent_History.DimRecentGivingFY17 Set GaveVia_FY17 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY17 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY17'

	update ODW.Recent_History.DimRecentGivingFY18 Set GaveVia_FY18 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY18 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY18'

	update ODW.Recent_History.DimRecentGivingFY18 Set GaveVia_FY18 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY18 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY18'

	update ODW.Recent_History.DimRecentGivingFY19 Set GaveVia_FY19 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY19 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY19'

	update ODW.Recent_History.DimRecentGivingFY19 Set GaveVia_FY19 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY19 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY19'

	update ODW.Recent_History.DimRecentGivingFY20 Set GaveVia_FY20 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY20 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.HC_Account
	where b.[Fiscal Year] = 'FY20'

	update ODW.Recent_History.DimRecentGivingFY20 Set GaveVia_FY20 = b.RandomID
	from ODW.Recent_History.DimRecentGivingFY20 (nolock) a 
	inner join #Randomizer (nolock) b on a.AccountID = b.SC_Account
	where b.[Fiscal Year] = 'FY20'

	update ODW.dbo.DimAccount set Account_Without_Contact = 'No'
	update ODW.dbo.DimAccount 
	set Account_Without_Contact = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	left outer join ODW.dbo.DimContact (nolock) b on a.[Account ID] = b.[Account ID]
	where b.[Account ID] is null

	update ODW.dbo.DimCampaignContact
	set [Salutation Line 1] = b.[Salutation Line 1]
	from ODW.dbo.DimCampaignContact (nolock) a
	inner join ODW.dbo.DimBiosAccountSalutation b on a.[Account ID] = b.Account

END


GO
