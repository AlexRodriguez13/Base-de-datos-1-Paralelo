--Database Mail

--1.Crear Cuenta y Perfil

--1-1.Create a Database Mail Account
execute msdb.dbo.sysmail_add_account_sp
@account_name='ABD2021',
@description='Mail account for use by all database users',
@email_address='alexanderya123@outlook.com',
@replyto_address='alexanderya123@outlook.com',
@display_name='Automated Mailer',
@mailserver_name='smtp.gmail.com',
@port=587,
@enable_SSL=1,
@username='alexanderya123@outlook.com',
@password='AlexBarbas1302';

--1-2.Create a Database Mail Profile
execute msdb.dbo.sysmail_add_profile_sp
@profile_name='ABD2021 Public Profile',
@description='Profile used for jobs mail';

--1-3.Add the account to the profile
execute msdb.dbo.sysmail_add_profileaccount_sp
@profile_name='ABD2021 Public Profile',
@account_name='ABD2021',
@sequence_number=1;

--1-4.Grant Access to the profile to all users int the msdb database
execute msdb.dbo.sysmail_add_principalprofile_sp
@profile_name='ABD2021 Public Profile',
@principal_name='public',
@is_default=1;

--2.Eliminar Cuenta y Perfil

--2-1.Desligar la cuenta del perfil
execute[msdb].DBO.[sysmail_delete_profileaccount_sp]
@profile_name='ABD2021 Public Profile',
@account_name='ABD2021';

--2-2.Eliminar cuenta
execute [msdb].DBO.[sysmail_delete_account_sp]
@account_name='ABD2021';

--2-3.Eliminar Profile
execute[msdb].DBO.[sysmail_delete_profile_sp]
@profile_name='ABD2021 Public Profile';

--3.Enviar Correo
exec msdb.dbo.sp_send_dbmail
@profile_name='ABD2021 Public Profile',
@recipients='alexanderya123@outlook.com',
@body='Esta es un testeo de envio de correo',
@subject='Automated Success Message';

--Enviar correo
exec msdb.dbo.sp_send_dbmail
@profile_name='ABD2021 Public Profile',
@recipients='alexanderya123@outlook.com',
@query='SELECT COUNT(*) FROM AdventureWorks2019.Production.WorkOrder
where duedate > "2004-04-30"
and datediff(dd,"2004-04-30",DueDate) < 2',
@subject='Work Order Count',
@attach_query_result_as_file=1;

--4.Operadores
use msdb 
go

--4-1.sp_adder_operator
exec dbo.sp_add_operator
@name=N'Tranferencias de Datos1',
@enabled=1,
@email_address=N'alexanderya123@outlook.com',
@weekday_pager_start_time=080000,
@weekday_pager_end_time=230000,
@pager_days=62;
GO

--4-2.sp_add_alert
exec msdb.dbo.sp_add_alert 
@name=N'Prueba',
@message_id=0,
@severity=14,
@enabled=1,
@delay_between_responses=0,
@include_event_description_in=1,
@notification_message=N'Esta es una alerta de prueba';
go

--4-3.sp_add_notification
exec msdb.dbo.sp_add_notification
@alert_name=N'Prueba',
@operator_name=N'Transferencia de Datos1',
@notification_method=1;
go

-------------------------------------------------------------
--Jobs
use msdb;
go

--1-1.creates a local category named AdminJobs
exec dbo.sp_add_category
@class=N'JOB',
@type=N'Local',
@name=N'AdminJobs1';
go

--1-2.Administrar Categorias
exec dbo.sp_update_job
@job_name=N'Job_name',
@category_name=N'[Uncategorized(Local)]';
go

--1-3.sp_add_job
sp_add_job [@job_name='job_name'],
[@enabled=enabled],
[@description='description'],
[@start_step_id=step_id],
[@category_name='category'],
[@category_id=category_id],
[@owner_login_name='login'],
[@notify_level_eventlog =  eventlog_level],
[@notify_level_email =  email_level],
[@notify_level_netsend =  netsend_level],
[@notify_level_page =  page_level],
[@notify_email_operator_name =  'email_name'],
[@notify_netsend_operator_name = 'netsend_name'],
[@notify_page_operator_name =  'page_name'],
[@delete_level =  delete_level],
[@job_id =  job_id OUTPUT];

--1-4.sp_add_jobstep
sp_add_jobstep [@job_id = job_id]
[@job_name ='Yader'],
[@step_id = step_id],
[@step_name = 'step_name'],
[@subsystem = 'subsystem'],
[@command = 'command'],
[@additional_parameters = 'parameters'],
[@cmdexec_success_code = code],
[@on_success_action = success_action],
[@on_success_step_id = success_step_id],
[@on_fail_action = fail_action],
[@on_fail_step_id = fail_step_id],
[@server = 'server'],
[@database_name = 'database'],
[@database_user_name = 'user'],
[@retry_attempts = retry_attempts],
[@retry_interval = retry_interval],
[@os_run_priority = run_priority],
[@output_file_name = 'file_name'],
[@flags = flags],
[@proxy_id = proxy_id],
[@proxy_name = 'proxy_name']


--1-5.sp_add_shedule
sp_add_schedule [@schedule_name ='schedule_name'],
[@enabled = enabled],
[@freq_type = freq_type],
[@freq_interval = freq_interval],
[@freq_subday_type = freq_subday_type],
[@freq_subday_interval = freq_subday_interval],
[@freq_relative_interval = freq_relative_interval],
[@freq_recurrence_factor = freq_recurrence_factor],
[@active_start_date = active_start_date],
[@active_end_date = active_end_date],
[@active_start_time = active_start_time],
[@active_end_time = active_end_time],
[@owner_login_name = 'owner_login_name' ],
[@schedule_uid = schedule_uid OUTPUT],
[@schedule_id = schedule_id OUTPUT],
[@originating_server = server_name] 

use msdb ; 
go
exec dbo.sp_add_schedule
@schedule_name = N'RunOnce', @freq_type = 1, @active_start_time = 233000 ;
go

--1-6.sp_attach_schedule
sp_attach_schedule [ @job_id = job_id], 
[@job_name = 'job_name'],
[@schedule_id = schedule_id],
[@schedule_name = 'schedule_name']

use msdb;
go
exec sp_add_schedule 
@schedule_name = N'NightlyJobs',
@freq_type = 4,
@freq_interval = 1,
@active_start_time = 010000; 
go

exec sp_attach_schedule 
@job_name = N'BackupDatabase', 
@schedule_name = N'NightlyJobs' ;
go

exec sp_attach_schedule 
@job_name = N'RunReports',
@schedule_name = N'NightlyJobs' ;
go
