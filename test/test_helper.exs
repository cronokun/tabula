# Recreate dirs required for tests:
File.mkdir_p!("./test/fixtures/boards/")
File.rm_rf("./test/release/")
File.mkdir_p!("./test/release/")

ExUnit.start()
