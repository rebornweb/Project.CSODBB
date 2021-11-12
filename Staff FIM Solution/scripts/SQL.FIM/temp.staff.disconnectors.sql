SELECT [object_id]
      ,[ma_id]
      ,[pobject_id]
      ,[rdn]
      ,[ancestors]
      ,[depth]
      ,[anchor]
      ,[partition_id]
      ,[creation_date]
      ,[is_provisioned]
      ,[disconnection_id]
      ,[disconnection_modification_date]
      ,[last_import_modification_date]
      ,[last_export_modification_date]
      ,[count_import_modications]
      ,[count_export_modications]
      ,[is_connector]
      ,[connector_state]
      ,[pending]
      ,[is_rename_retry]
      ,[is_reference_retry]
      ,[is_rebuild_in_progress]
      ,[is_seen_by_import]
      ,[is_phantom_parent]
      ,[is_phantom_link]
      ,[is_phantom_delete]
      ,[is_full_sync]
      ,[is_obsoletion]
      ,[is_pending_reference_delete]
      ,[import_operation]
      ,[export_operation]
      ,[is_import_error]
      ,[count_import_error_retries]
      ,[initial_import_error_date]
      ,[last_import_error_date]
      ,[import_error_code]
      ,[is_export_error]
      ,[count_export_error_retries]
      ,[initial_export_error_date]
      ,[last_export_error_date]
      ,[export_error_code]
      ,[current_export_batch_number]
      ,[current_export_sequence_number]
      ,[unapplied_export_batch_number]
      ,[unapplied_export_sequencer_number]
      ,[original_export_batch_number]
      ,[original_export_sequencer_number]
      ,[key_id]
      ,[hologram]
      ,[deltas]
      ,[import_error_detail]
      ,[export_error_detail]
      ,[transient_dn]
      ,[transient_details]
      ,[password_change_history]
      ,[is_pending_reference_rename]
      ,[pending_moveop]
      ,[password_incoming_timestamp]
      ,[password_outgoing_timestamp]
      ,[applied_entries]
      ,[object_type]
      ,[is_fullsync_started]
      ,[is_pending_obsoletion]
  FROM [FIMSynchronizationService].[dbo].[mms_connectorspace] with (nolock)
  where [ma_id] = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
  and pobject_id in (
	select [object_id] from [FIMSynchronizationService].[dbo].[mms_connectorspace] with (nolock)
    where [ma_id] = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
	and [object_type] = 'organizationalUnit'
	and pobject_id in (
		select [object_id] from [FIMSynchronizationService].[dbo].[mms_connectorspace] with (nolock)
	    where [ma_id] = (select ma_id from dbo.mms_management_agent with (nolock) where ma_name = 'Staff')
		and [object_type] = 'organizationalUnit'
		and [rdn] in ('OU=Staff')
	)
	and [rdn] in (
		'OU=BBI',
		'OU=Centacare',
		'OU=CSO',
		'OU=Duplicate Accounts',
		'OU=Office of the Bishop',
		'OU=Parishes',
		'OU=UnknownOrganisation'
		--'OU=Staff'
	)
  )
  --and [rdn] = 'CN=Colleen Dopper'
  and [is_connector] = 0
  and [object_type] = 'user'
  and [rdn] not like '%admin%'
  and [rdn] not like '%svc%'
  and [rdn] not like '%sandbox%'
  and [rdn] not like '%service%'
  and [rdn] not like '%web%'
  and [rdn] not like '%wyd %'
  and [rdn] not like '% dev'
  and [rdn] not like '% uat'
GO


