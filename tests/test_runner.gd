extends SceneTree

const TestDataLoader = preload("res://tests/unit/test_data_loader.gd")

func _init() -> void:
	print("=========================================")
	print("      OPEN FOOTBALL — TEST RUNNER        ")
	print("=========================================")
	
	var success := true
	success = TestDataLoader.run_all_tests() and success
	
	if success:
		print("[SUCCESS] TODOS OS TESTES PASSARAM COM EXCELENCIA!")
		quit(0)
	else:
		push_error("[FAILURE] ALGUNS TESTES FALHARAM!")
		quit(1)
