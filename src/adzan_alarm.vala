/**
 * Adzan Alarm
 * Aplikasi pengingat adzan dengan fitur:
 * - Penunjuk arah kiblat
 * - Calendar
 * - Custom setting
 * - Notifikasi
 *
 * @author    Agus Susilo
 * @date      1 Juni 2013 19:00
 * @version   0.10
 * @copyright (C) 2013 Susilolab
 */

public class AdzanAlarm: Gtk.Window
{
	private Gtk.Builder builder;
	private Gtk.Window win;
	private Gtk.Button btn_quit;
	private Gtk.Button btn_close;
	private Gtk.Button btn_prayer_cal;
	private Gtk.Button btn_preference;

	private Gtk.StatusIcon tray_icon;
	private Gtk.Menu menu_system;

	private Gtk.Label lbl_subh;
	private Gtk.Label lbl_shorook;
	private Gtk.Label lbl_dhuhr;
	private Gtk.Label lbl_asr;
	private Gtk.Label lbl_maghreb;
	private Gtk.Label lbl_isha;

	/**
	 * Constructor
	 */
	public AdzanAlarm() {
		try{
			builder = new Gtk.Builder();
			builder.add_from_file("share/ui/minbar.glade");
			builder.connect_signals(null);

		}catch(Error e) {
			stderr.printf("%s\n", e.message);
		}
	}

	/**
	 * Initialize components such as window, label, button, load setting etc.
	 *
	 * @return void
	 */
	public void init() {
		win = builder.get_object("win_main") as Gtk.Window;
		win.title           = "Prayer Time";
		win.window_position = Gtk.WindowPosition.CENTER;
		win.destroy.connect(Gtk.main_quit);
		try{
			win.icon = new Gdk.Pixbuf.from_file("share/icons/praytime.png");
			win.icon = Gtk.IconTheme.get_default().load_icon("praytime", 48, 0);
		}catch(Error e) {
			stderr.printf("%s\n", e.message);
		}

		btn_quit = builder.get_object("btn_quit") as Gtk.Button;
		btn_quit.clicked.connect(Gtk.main_quit);

		btn_close = builder.get_object("btn_close") as Gtk.Button;
		btn_close.clicked.connect(btn_close_clicked);

		btn_prayer_cal = builder.get_object("btn_prayer_cal") as Gtk.Button;
		btn_prayer_cal.clicked.connect(btn_prayer_cal_clicked);

		btn_preference = builder.get_object("btn_preferences") as Gtk.Button;
		btn_preference.clicked.connect(btn_preference_clicked);

		this.lbl_subh    = builder.get_object("lbl_subh") as Gtk.Label;
		this.lbl_shorook = builder.get_object("lbl_shorook") as Gtk.Label;
		this.lbl_dhuhr   = builder.get_object("lbl_dhuhr") as Gtk.Label;
		this.lbl_asr     = builder.get_object("lbl_asr") as Gtk.Label;
		this.lbl_maghreb = builder.get_object("lbl_maghreb") as Gtk.Label;
		this.lbl_isha    = builder.get_object("lbl_isha") as Gtk.Label;

		win.show_all();
		this.setPrayerTime();
	}

	/**
	 * Button prayer calendar window listener
	 * @return void
	 */
	public void btn_prayer_cal_clicked() {
	    var app = new Calendar();
	    app.init();
	}

	/**
	 * Button preference window listener
	 * @return void
	 */
	public void btn_preference_clicked() {
	    var app = new Preference();
	    app.init();
	}

	/**
	 * Button close listener
	 * @return void
	 */
	public void btn_close_clicked() {
		// Tray icons
		tray_icon = new Gtk.StatusIcon.from_stock(Gtk.Stock.HOME);
		tray_icon.set_tooltip_text("Tray");
		tray_icon.set_visible(true);

		tray_icon.activate.connect(about_clicked);
		create_menu_system();
		tray_icon.popup_menu.connect(menu_system_popup);
		win.iconify();
	}

	/**
	 * Create menu system
	 *
	 * @return void
	 */
	public void create_menu_system() {
		menu_system = new Gtk.Menu();
		var menu_about = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.ABOUT, null);
		menu_about.activate.connect(about_clicked);
		menu_system.append(menu_about);

		var menu_quit = new Gtk.ImageMenuItem.from_stock(Gtk.Stock.QUIT, null);
		menu_quit.activate.connect(Gtk.main_quit);
		menu_system.append(menu_quit);
		menu_system.show_all();
	}

	/**
	 * Memunculkan sistem menu popup
	 *
	 * @return void
	 */
	private void menu_system_popup(uint button, uint time) {
		menu_system.popup(null, null, null, button, time);
	}

	/**
	 * Event about listener
	 *
	 * @access private
	 * @return void
	 */
	private void about_clicked() {
		var about = new Gtk.AboutDialog();
		about.set_version("0.0.0");
		about.set_program_name("Tray");
		about.set_comments("Tray Utility");
		about.set_copyright("vala");
		about.run();
		about.hide();
	}

	/**
	 * Set waktu sholat ke label
	 *
	 * @access private
	 * @return void
	 */
	private void setPrayerTime() {
		PrayTime pt = new PrayTime();
		double lat = -7.8000;
        double lng = 110.3667;

        DateTime dt = new DateTime.now_local();
        int dt_y, dt_m, dt_d;
		dt_y  = dt.get_year();
		dt_m  = dt.get_month();
		dt_d  = dt.get_day_of_month();

		pt.setCalcMethod(3);
        pt.setAsrMethod(0);

        string[] sch_pray = pt.getPrayerTimes(dt_y, dt_m, dt_d, lat, lng, 7);

		this.lbl_subh.label    = sch_pray[0];
		this.lbl_shorook.label = sch_pray[1];
		this.lbl_dhuhr.label   = sch_pray[2];
		this.lbl_asr.label     = sch_pray[3];
		this.lbl_maghreb.label = sch_pray[5];
		this.lbl_isha.label    = sch_pray[6];
	}

	static int main(string[] args) {
	    Gtk.init(ref args);

	    var app = new AdzanAlarm();
	    app.init();

	    Gtk.main();

		return 0;
	}
}