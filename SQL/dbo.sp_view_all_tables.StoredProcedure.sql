USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_view_all_tables]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_view_all_tables] 
AS
SET NOCOUNT ON
select * from sys.tables order by name

GO
