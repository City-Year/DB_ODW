USE [ODW]
GO
/****** Object:  Table [dbo].[DimAccountGivingHistory]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAccountGivingHistory](
	[AccountID] [int] NOT NULL,
	[Site] [varchar](250) NULL,
	[Year] [varchar](250) NULL,
	[Hard] [money] NULL,
	[Soft] [money] NULL,
	[Total] [money] NULL,
	[PandT] [money] NULL,
	[Total_With_PandT] [money] NULL,
	[Year_Numeric] [int] NULL,
	[GIT] [money] NULL,
	[Region] [varchar](250) NULL
) ON [INDEXES]

GO
