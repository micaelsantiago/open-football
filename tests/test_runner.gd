extends SceneTree

const TestDataLoader = preload("res://tests/unit/test_data_loader.gd")
const TestDomainState = preload("res://tests/unit/test_domain_state.gd")
const TestMatchEngine = preload("res://tests/unit/test_match_engine.gd")
const TestIsometricGrid = preload("res://tests/unit/test_isometric_grid.gd")
const TestUIAndManagement = preload("res://tests/unit/test_ui_and_management.gd")
const TestMatchPresentationAndStandings = preload("res://tests/unit/test_match_presentation_and_standings.gd")

func _init() -> void:
	print("=========================================")
	print("      OPEN FOOTBALL — TEST RUNNER        ")
	print("=========================================")
	
	var success := true
	success = TestDataLoader.run_all_tests() and success
	success = TestDomainState.run_all_tests() and success
	success = TestMatchEngine.run_all_tests() and success
	success = TestIsometricGrid.run_all_tests() and success
	success = TestUIAndManagement.run_all_tests() and success
	success = TestMatchPresentationAndStandings.run_all_tests() and success
	
	if success:
		print("[SUCCESS] TODOS OS TESTES PASSARAM COM EXCELENCIA!")
		quit(0)
	else:
		push_error("[FAILURE] ALGUNS TESTES FALHARAM!")
		quit(1)
