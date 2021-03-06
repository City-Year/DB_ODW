USE [ODW]
GO
/****** Object:  Table [Recent_History].[DimRecentGivingFY20]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Recent_History].[DimRecentGivingFY20](
	[AccountID] [int] NULL,
	[BR_HC_FY20] [money] NULL,
	[BR_SC_FY20] [money] NULL,
	[BR_PandT_FY20] [money] NULL,
	[BOS_HC_FY20] [money] NULL,
	[BOS_SC_FY20] [money] NULL,
	[BOS_PandT_FY20] [money] NULL,
	[CF_HC_FY20] [money] NULL,
	[CF_SC_FY20] [money] NULL,
	[CF_PandT_FY20] [money] NULL,
	[CHI_HC_FY20] [money] NULL,
	[CHI_SC_FY20] [money] NULL,
	[CHI_PandT_FY20] [money] NULL,
	[CLE_HC_FY20] [money] NULL,
	[CLE_SC_FY20] [money] NULL,
	[CLE_PandT_FY20] [money] NULL,
	[CIA_HC_FY20] [money] NULL,
	[CIA_SC_FY20] [money] NULL,
	[CIA_PandT_FY20] [money] NULL,
	[CUS_HC_FY20] [money] NULL,
	[CUS_SC_FY20] [money] NULL,
	[CUS_PandT_FY20] [money] NULL,
	[DEN_HC_FY20] [money] NULL,
	[DEN_SC_FY20] [money] NULL,
	[DEN_PandT_FY20] [money] NULL,
	[DET_HC_FY20] [money] NULL,
	[DET_SC_FY20] [money] NULL,
	[DET_PandT_FY20] [money] NULL,
	[HQ_HC_FY20] [money] NULL,
	[HQ_SC_FY20] [money] NULL,
	[HQ_PandT_FY20] [money] NULL,
	[JAX_HC_FY20] [money] NULL,
	[JAX_SC_FY20] [money] NULL,
	[JAX_PandT_FY20] [money] NULL,
	[LR_HC_FY20] [money] NULL,
	[LR_SC_FY20] [money] NULL,
	[LR_PandT_FY20] [money] NULL,
	[LA_HC_FY20] [money] NULL,
	[LA_SC_FY20] [money] NULL,
	[LA_PandT_FY20] [money] NULL,
	[LOU_HC_FY20] [money] NULL,
	[LOU_SC_FY20] [money] NULL,
	[LOU_PandT_FY20] [money] NULL,
	[MIA_HC_FY20] [money] NULL,
	[MIA_SC_FY20] [money] NULL,
	[MIA_PandT_FY20] [money] NULL,
	[MIL_HC_FY20] [money] NULL,
	[MIL_SC_FY20] [money] NULL,
	[MIL_PandT_FY20] [money] NULL,
	[NH_HC_FY20] [money] NULL,
	[NH_SC_FY20] [money] NULL,
	[NH_PandT_FY20] [money] NULL,
	[NO_HC_FY20] [money] NULL,
	[NO_SC_FY20] [money] NULL,
	[NO_PandT_FY20] [money] NULL,
	[NYC_HC_FY20] [money] NULL,
	[NYC_SC_FY20] [money] NULL,
	[NYC_PandT_FY20] [money] NULL,
	[ORL_HC_FY20] [money] NULL,
	[ORL_SC_FY20] [money] NULL,
	[ORL_PandT_FY20] [money] NULL,
	[PHI_HC_FY20] [money] NULL,
	[PHI_SC_FY20] [money] NULL,
	[PHI_PandT_FY20] [money] NULL,
	[RI_HC_FY20] [money] NULL,
	[RI_SC_FY20] [money] NULL,
	[RI_PandT_FY20] [money] NULL,
	[SAC_HC_FY20] [money] NULL,
	[SAC_SC_FY20] [money] NULL,
	[SAC_PandT_FY20] [money] NULL,
	[SA_HC_FY20] [money] NULL,
	[SA_SC_FY20] [money] NULL,
	[SA_PandT_FY20] [money] NULL,
	[SJ_HC_FY20] [money] NULL,
	[SJ_SC_FY20] [money] NULL,
	[SJ_PandT_FY20] [money] NULL,
	[SEA_HC_FY20] [money] NULL,
	[SEA_SC_FY20] [money] NULL,
	[SEA_PandT_FY20] [money] NULL,
	[TUL_HC_FY20] [money] NULL,
	[TUL_SC_FY20] [money] NULL,
	[TUL_PandT_FY20] [money] NULL,
	[WASH_HC_FY20] [money] NULL,
	[WASH_SC_FY20] [money] NULL,
	[WASH_PandT_FY20] [money] NULL,
	[TOTAL_FY20] [money] NULL,
	[TOTAL_SOFT_FY20] [money] NULL,
	[TOTAL_HARD_FY20] [money] NULL,
	[TOTAL_FY20_with_PandT] [money] NULL,
	[GaveVia_FY20] [numeric](18, 0) NULL,
	[DAL_HC_FY20] [money] NULL,
	[DAL_SC_FY20] [money] NULL,
	[DAL_PandT_FY20] [money] NULL
) ON [INDEXES]

GO
