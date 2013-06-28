// valac -X -lm --pkg gtk+-3.0 pray_time.vala minbar.vala -o minbar

public class Calendar: Gtk.Dialog
{
	private Gtk.Builder builder;
	private Gtk.Dialog dlg;
	private Gtk.Button btn_close;
	private Gtk.Button btn_today;
	private Gtk.Calendar calendar;

	private Gtk.Label lbl_subh;
	private Gtk.Label lbl_sunrise;
	private Gtk.Label lbl_dhuhr;
	private Gtk.Label lbl_asr;
	private Gtk.Label lbl_maghreb;
	private Gtk.Label lbl_isha;

	public Calendar() {
		try{
			builder = new Gtk.Builder();
			builder.add_from_file("share/ui/calendar.glade");
			builder.connect_signals(null);

		}catch(Error e) {
			stderr.printf("%s\n", e.message);
		}
	}

	public int[] getCurrentDate() {
        DateTime dt = new DateTime.now_local();
        int d, m, y;

        d = dt.get_day_of_month();
        m = dt.get_month();
        y = dt.get_year();
        return new int[]{y, m, d};
	}

	public void init() {
		this.dlg = builder.get_object("dlg_calendar") as Gtk.Dialog;
		this.dlg.title           = "Calendar - Prayer Time";
		// dlg.window_position = Gtk.WindowPosition.CENTER;
		this.dlg.destroy.connect( () => {
			dlg.hide();
		});

		this.calendar = builder.get_object("calendar1") as Gtk.Calendar;
		this.calendar.day_selected.connect(calendar_selected);

		btn_close = builder.get_object("btn_close") as Gtk.Button;
		btn_close.clicked.connect( () => {
			this.dlg.hide();
		});

		btn_today = builder.get_object("btn_today") as Gtk.Button;
		btn_today.clicked.connect(btn_today_clicked);

		this.lbl_subh    = builder.get_object("lbl_subh") as Gtk.Label;
		this.lbl_sunrise = builder.get_object("lbl_sunrise") as Gtk.Label;
		this.lbl_dhuhr   = builder.get_object("lbl_dhuhr") as Gtk.Label;
		this.lbl_asr     = builder.get_object("lbl_asr") as Gtk.Label;
		this.lbl_maghreb = builder.get_object("lbl_maghreb") as Gtk.Label;
		this.lbl_isha    = builder.get_object("lbl_isha") as Gtk.Label;

		dlg.show_all();
		this.setDate();
	}

	public void setDate() {
		int[] date = this.getCurrentDate();

		this.calendar.day   = date[2];
		this.calendar.month = date[1]-1;
		this.calendar.year  = date[0];
	}

	public void btn_today_clicked() {
		int[] date = this.getCurrentDate();

		this.calendar.day   = date[2];
		this.calendar.month = date[1]-1;
		this.calendar.year  = date[0];
		this.setPrayerTime(this.calendar.year, this.calendar.month, this.calendar.day);
	}

	public void calendar_selected() {
		this.setPrayerTime(this.calendar.year, this.calendar.month, this.calendar.day);
	}

	public void btn_close_clicked() {
	}

	private void setPrayerTime(int y, int m, int d) {
		PrayTime pt = new PrayTime();
		double lat = -7.8000;
        double lng = 110.3667;

		pt.setCalcMethod(3);
        pt.setAsrMethod(0);

        string[] sch_pray = pt.getPrayerTimes(y, m, d, lat, lng, 7);

		this.lbl_subh.label    = sch_pray[0];
		this.lbl_sunrise.label = sch_pray[1];
		this.lbl_dhuhr.label   = sch_pray[2];
		this.lbl_asr.label     = sch_pray[3];
		this.lbl_maghreb.label = sch_pray[5];
		this.lbl_isha.label    = sch_pray[6];
	}

	private void connect_signals () {
		this.response.connect (on_response);
	}

	private void on_response (Gtk.Dialog source, int response_id) {
		switch (response_id) {
		case Gtk.ResponseType.HELP:
			// show_help ();
			break;
		case Gtk.ResponseType.APPLY:
			break;
		case Gtk.ResponseType.CLOSE:
			this.destroy ();
			break;
		}
	}
}