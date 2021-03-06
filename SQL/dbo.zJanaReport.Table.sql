USE [ODW]
GO
/****** Object:  Table [dbo].[zJanaReport]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zJanaReport](
	[# Guests] [decimal](18, 0) NULL,
	[Seat Number] [varchar](255) NULL,
	[Guest Of] [varchar](18) NULL,
	[Guest Of Name] [varchar](250) NULL,
	[Seating Description] [varchar](255) NULL,
	[Table Name] [varchar](255) NULL,
	[Attendance Status] [varchar](255) NULL,
	[Attendance Date] [datetime] NULL,
	[Name] [varchar](80) NOT NULL,
	[Contact ID] [varchar](18) NULL,
	[First Name] [varchar](40) NULL,
	[Last Name] [varchar](80) NULL,
	[Full Name] [varchar](121) NULL,
	[City Year Alumni] [int] NULL,
	[Account Name] [varchar](250) NULL,
	[Registered Status] [varchar](255) NULL,
	[Registered Date] [datetime] NULL,
	[Invited by] [varchar](255) NULL,
	[Representative Of Name] [varchar](250) NULL,
	[Campaign Group 1 Name] [varchar](250) NULL,
	[Campaign Group 2 Name] [varchar](250) NULL,
	[Campaign Group 3 Name] [varchar](250) NULL,
	[Registered Table Name] [varchar](255) NULL,
	[Registered Venue] [varchar](18) NULL,
	[Preferred Mailing Address Value] [varchar](250) NULL,
	[Preferred Email Value] [varchar](250) NULL,
	[Preferred Phone Value] [varchar](250) NULL,
	[Street] [varchar](250) NULL,
	[City] [varchar](250) NULL,
	[State] [varchar](250) NULL,
	[Zip] [varchar](250) NULL,
	[Gave at Event?] [int] NULL,
	[Event Gift Amount] [decimal](18, 2) NULL,
	[BOS_HC_FY10] [money] NULL,
	[BOS_SC_FY10] [money] NULL,
	[BOS_HC_FY11] [money] NULL,
	[BOS_SC_FY11] [money] NULL,
	[BOS_HC_FY12] [money] NULL,
	[BOS_SC_FY12] [money] NULL,
	[BOS_HC_FY13] [money] NULL,
	[BOS_SC_FY13] [money] NULL,
	[BOS_HC_FY14] [money] NULL,
	[BOS_SC_FY14] [money] NULL,
	[BOS_HC_FY15] [money] NULL,
	[BOS_SC_FY15] [money] NULL,
	[BOS_HC_FY16] [money] NULL,
	[BOS_SC_FY16] [money] NULL,
	[BOS_HC_FY17] [money] NULL,
	[BOS_SC_FY17] [money] NULL
) ON [PRIMARY]

GO
