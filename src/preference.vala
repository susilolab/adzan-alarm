public class Preference: Gtk.Dialog
{
	enum Column{
		CALC_METHOD
	}
	public string[] calc_method = {
		"Egyptian General Authority of Survey",
		"University of Islamic Science, Karachi (Shaf'i)",
		"University of Islamic Science, Karachi (Hanafi)",
		"Islamic Society of North America",
		"Muslim World League (MWL)",
		"Umm Al-Qurra, Saudi Arabia"
	};

	private Gtk.Builder builder;
	private Gtk.Dialog dlg;
	private Gtk.Button btn_ok;
	private Gtk.Button btn_cancel;
	private Gtk.Entry txt_city_name;
	private Gtk.SpinButton spinbtn_lat;
	private Gtk.SpinButton spinbtn_lng;
	private Gtk.SpinButton spinbtn_time_zone;
	private Gtk.ComboBox cbox_calc_method;

	private Utils utils;

	public Preference() {
		try{
			builder = new Gtk.Builder();
			builder.add_from_file("share/ui/pref.glade");
			builder.connect_signals(null);

		}catch(Error e) {
			stderr.printf("%s\n", e.message);
		}
		this.utils = new Utils();
	}

	public void init() {
		this.dlg = builder.get_object("dlg_preference") as Gtk.Dialog;
		this.dlg.title           = "Preference - Prayer Time";
		// dlg.window_position = Gtk.WindowPosition.CENTER;
		this.dlg.destroy.connect( () => {
			this.dlg.hide();
		});

		btn_ok = builder.get_object("btn_ok") as Gtk.Button;
		btn_ok.clicked.connect(btn_ok_clicked);

		btn_cancel = builder.get_object("btn_cancel") as Gtk.Button;
		btn_cancel.clicked.connect( () => {
			this.dlg.hide();
		});

		this.txt_city_name     = builder.get_object("txt_city_name") as Gtk.Entry;
		this.spinbtn_lat       = builder.get_object("spinbtn_lat") as Gtk.SpinButton;
		this.spinbtn_lng       = builder.get_object("spinbtn_lng") as Gtk.SpinButton;
		this.spinbtn_time_zone = builder.get_object("spinbtn_time_zone") as Gtk.SpinButton;
		this.cbox_calc_method  = builder.get_object("cbox_calc_method") as Gtk.ComboBox;

		Gtk.ListStore liststore = new Gtk.ListStore(1, typeof(string));

		for(int i=0; i<this.calc_method.length; i++) {
			Gtk.TreeIter iter;
			liststore.append(out iter);
			liststore.set(iter, Column.CALC_METHOD, this.calc_method[i]);
		}

		this.cbox_calc_method.set_model(liststore);
		Gtk.CellRendererText cell = new Gtk.CellRendererText();
		this.cbox_calc_method.pack_start(cell, false);
		this.cbox_calc_method.set_attributes(cell, "text", Column.CALC_METHOD);

		this.cbox_calc_method.set_active(0);
		// combobox.changed.connect(this.item_changed);
		this.dlg.show_all();
		this.loadSetting();
	}

	public void loadSetting() {
		string[] setting = this.utils.getSetting();
		this.txt_city_name.text     = setting[Utils.Settings.CITY_NAME];
		this.spinbtn_lat.text       = setting[Utils.Settings.LAT];
		this.spinbtn_lng.text       = setting[Utils.Settings.LNG];
		this.spinbtn_time_zone.text = setting[Utils.Settings.TIME_ZONE];
	}

	public void btn_ok_clicked() {
		this.dlg.hide();
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