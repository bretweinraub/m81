	'<a href="http://' || 'usbohp380-7/' || substr (collections.value, instr (collections.value, '/', 1, 3) + 1, instr (collections.value, '/', 1, 4) - instr (collections.value, '/', 1, 3) - 1) || '/wlogs/' || task.task_id || '/">link</a>' results,
	'<a href="http://' || 'usbohp380-7/' || substr (collections.value, instr (collections.value, '/', 1, 3) + 1, instr (collections.value, '/', 1, 4) - instr (collections.value, '/', 1, 3) - 1) || '/taskData/' || task.task_id || '/">link</a>' internal,