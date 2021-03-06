USE [ODW]
GO
/****** Object:  Table [dbo].[FactDonor]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactDonor](
	[OpportunityID] [varchar](18) NULL,
	[OppAccountID] [varchar](18) NULL,
	[OppCampaignID] [varchar](18) NULL,
	[AllocationID] [int] NOT NULL,
	[AccountID] [int] NOT NULL,
	[Hard] [decimal](18, 2) NULL,
	[Soft] [decimal](38, 2) NULL,
	[FY_Hard] [varchar](255) NULL,
	[FY_Soft] [varchar](256) NULL
) ON [PRIMARY]

GO
