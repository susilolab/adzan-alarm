class Utils: GLib.Object
{
	public Sqlite.Database db;
	public Sqlite.Statement stmt;
	public Sqlite.Statement upd;

	public enum Settings{
		ID,
		PLAY_ADZAN,
		LAT,
		LNG,
		CITY_NAME,
		TIME_ZONE,
		START_MINIMIZED,
		NOTIFY_SET,
		NOTIFY_MINUTE,
		CALC_METHOD,
		ADZAN_SUBH,
		ADZAN_NORMAL
	}

	public Utils() {
	}

	public void setSetting(Settings setting, string val) {
	}

	public string[] getSetting() {
		Sqlite.Database.open("share/data/settings.db", out this.db);
		string sql = "SELECT * FROM setting";

		int rc   = this.db.prepare_v2(sql, -1, out this.stmt, null);
		int cols = this.stmt.column_count();
		string[] result = new string[cols];

		do {
			rc = this.stmt.step();
			switch(rc) {
				case Sqlite.ROW:
					for(int col = 0; col<cols; col++) {
						string txt = this.stmt.column_text(col);
						result[col] = txt;
					}
					break;
			}
		}while(rc == Sqlite.ROW);

		return result;
	}
}