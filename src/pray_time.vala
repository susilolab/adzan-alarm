public class PrayTime
{
	public int jafari      = 0;
	public int karachi     = 1;
	public int isna        = 2;
	public int mwl         = 3;
	public int makkah      = 4;
	public int eqypt       = 5;
	public int custom      = 6;
	public int tehran      = 7;

	public int shaffi      = 0;
	public int hanafi      = 1;

	public int none        = 0;
	public int midnight    = 1;
	public int one_seventh = 2;
	public int angle_based = 3;

	public int time24      = 0;
	public int time12      = 1;
	public int time12_ns   = 2;
	public int floats      = 3;

	public string[] time_names = {
		"Fajr",
		"Sunrise",
		"Dhuhr",
		"Asr",
		"Sunset",
		"Maghrib",
		"Isha"
	};
	public string invalid_time = "-----";

	public int calc_method      = 3;
	public int asr_juristic     = 0;
	public int dhuhr_minutes    = 0;
	public int adjust_high_lats = 1;
	public int time_format      = 0;

	public double lat;
	public double lng;
	public double time_zone;
	public double jdate;

	private int num_iterations = 1;
	public double[,] method_params = {
		{16, 0, 4, 0, 14},
		{18, 1, 0, 0, 18},
		{15, 1, 0, 0, 15},
		{18, 1, 0, 0, 17},
		{18.5, 1, 0, 1, 90},
		{19.5, 1, 0, 0, 17.5},
		{17.7, 0, 4.5, 0, 14},
		{18, 1, 0, 0, 17}
	};

	public PrayTime(int method_id=0) {
		this.setCalcMethod(method_id);
	}

	public string[] getPrayerTimes(int year, int month , int day , double latitude, double  longitude, double time_zone) {
		return this.getDatePrayerTimes(year, month+ 1, day, latitude, longitude, time_zone);
	}

	public void setCalcMethod(int method_id) {
		this.calc_method = method_id;
	}

	public string[] getDatePrayerTimes(int year, int month, int day, double latitude, double longitude, double time_zone) {
		this.lat       = latitude;
		this.lng       = longitude;
		this.time_zone = time_zone;
		this.jdate     = this.julianDate(year, month, day) - longitude/ (15 * 24);
		return this.computeDayTimes();
	}

	public double julianDate(int year, int month, int day) {
		if(month <= 2) {
			year  -= 1;
			month += 12;
		}
		var a = Math.floor( (double)year / 100);
		var b = 2 - a + Math.floor(a / 4);

		var jd = Math.floor(365.25 * ((double)year + 4716)) + Math.floor(30.6001 * ((double)month + 1)) + (double)day + b - 1524.5;
		return jd;
	}

	public string[] computeDayTimes() {
		double[] times = {5, 6, 12, 13, 18, 18, 18};
		int i = 0;
		for(i=1; i<= this.num_iterations; i++) {
			times = this.computeTimes(times);
		}

		times = this.adjustTimes(times);
		return this.adjustTimesFormat(times);
	}

	public double computeTime(double g, double t) {
		double D   = this.sunDeclination(this.jdate + t);
		double Z   = this.computeMidDay(t);
		double beg = (-this.dsin(g)- this.dsin(D)* this.dsin(this.lat));
		double mid = (this.dcos(D)* this.dcos(this.lat));
		double V   = this.darccos(beg/mid) / 15.0;
		return Z + (g > 90? -V: V);
	}

	public double[] computeTimes (double[] times) {
		double[] t = this.dayPortion(times);

		double Fajr    = this.computeTime(180.0- this.method_params[this.calc_method,0], t[0]);
		double Sunrise = this.computeTime(180.0- 0.833, t[1]);
		double Dhuhr   = this.computeMidDay(t[2]);
		double Asr     = this.computeAsr(1+ this.asr_juristic, t[3]);
		double Sunset  = this.computeTime(0.833, t[4]);;
		double Maghrib = this.computeTime(this.method_params[this.calc_method,2], t[5]);
		double Isha    = this.computeTime(this.method_params[this.calc_method,4], t[6]);

		return new double[] {Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha};
	}

	public double computeAsr(int step, double t) {
		double d = this.sunDeclination(this.jdate + t);
		double g = -this.darccot((double)step + this.dtan(Math.fabs(this.lat - d)) );
		return this.computeTime(g, t);
	}

	public double computeMidDay(double t) {
		double T = this.equationOfTime(this.jdate + t);
		double z = this.fixHour(12 - T);
		return z;
	}

	public double sunDeclination(double jd) {
		return this.sunPosition(jd)[0];
	}

	public double[] sunPosition(double jd) {
		double D = jd - 2451545.0;
		double g = this.fixAngle(357.529 + 0.98560028* D);
		double q = this.fixAngle(280.459 + 0.98564736* D);
		double L = this.fixAngle(q + 1.915* this.dsin(g) + 0.020* this.dsin(2*g));

		double R = 1.00014 - 0.01671* this.dcos(g) - 0.00014* this.dcos(2*g);
		double e = 23.439 - 0.00000036* D;

		double d = this.darcsin(this.dsin(e)* this.dsin(L));
		double RA = this.darctan2(this.dcos(e)* this.dsin(L), this.dcos(L))/ 15;
		RA = this.fixHour(RA);
		double  EqT = q/15 - RA;

		return new double[] {d, EqT};
	}

	public double equationOfTime(double jd) {
		return this.sunPosition(jd)[1];
	}

	public string floatToTime12NS(double time) {
		return this.floatToTime12(time, true);
	}

	public string floatToTime12(double time, bool noSuffix) {
		if(time < 0)
			return this.invalid_time;

		time           = this.fixHour(time+ 0.5/ 60);  // add 0.5 minutes to round
		double hours   = Math.floor(time);
		double minutes = Math.floor((time- hours)* 60);
		string suffix  = hours >= 12 ? " pm" : " am";
		hours          = (hours+ 12 -1)% 12+ 1;
		return (hours.to_string())+":"+ this.twoDigitsFormat((int)minutes)+ (noSuffix ? "" : suffix);
	}

	public string floatToTime24(double time) {
		if (time < 0)
			return this.invalid_time;

		time = this.fixHour(time+ 0.5/ 60);  // add 0.5 minutes to round
		double  hours = Math.floor(time);
		double minutes = Math.floor((time- hours)* 60);
		return this.twoDigitsFormat((int)hours)+":"+ this.twoDigitsFormat((int)minutes);
	}

	public void setTimeFormat(int timeFormat) {
		this.time_format = timeFormat;
	}

	public void setAsrMethod(int method_id) {
		if(method_id < 0 || method_id > 1)
			return;
		this.asr_juristic = method_id;
	}

	public void setFajrAngle(double angle) {
		this.setCustomParams(new int[]{ (int)angle, -1, -1, -1, -1});
	}

	public void setMaghribAngle(double angle) {
		this.setCustomParams(new int[]{-1, 0, (int)angle, -1, -1});
	}

	public void setMaghribMinutes(int minutes) {
		this.setCustomParams(new int[]{-1, -1, minutes, -1, -1});
	}

	public void setIshaAngle(double angle) {
		this.setCustomParams(new int[]{-1, -1, -1, 0, (int)angle});
	}

	public void setIshaMinutes(int minutes) {
		this.setCustomParams(new int[]{-1, -1, -1, -1, minutes});
	}

	public void setDhuhrMinutes(int minutes) {
		this.dhuhr_minutes = minutes;
	}

	public void setCustomParams(int[] param) {
		for(int i=0; i<5; i++) {
			if(param[i] == -1)
				this.method_params[this.custom, i] = this.method_params[this.calc_method, i];
			else
				this.method_params[this.custom, i] = (double)param[i];
		}
		this.calc_method = this.custom;
	}

	public string twoDigitsFormat(int num) {
		return (num < 10)? "0" + num.to_string(): num.to_string();
	}

	public double getTimeDiff(double c1, double c2) {
		double diff = this.fixHour(c2 - c1);
		return diff;
	}

	public double[] dayPortion(double[] times) {
		for (int i=0; i< times.length; i++) {
	        times[i] /= 24;
	    }
		return times;
	}

	public double nightPortion(double angle) {
		double val = 0;
		if (this .adjust_high_lats== this.angle_based)
			val = 1.0/60.0* angle;
		if (this.adjust_high_lats == this.midnight)
			val = 1.0/2.0;
		if (this.adjust_high_lats == this.one_seventh)
			val =1.0/7.0;

		return val;
	}

	public double[] adjustTimes(double[] times) {
		double[] time = times;
		for(int i=0; i<7; i++) {
			times[i] += this.time_zone - this.lng / 15;
	    }

		times[2] += this.dhuhr_minutes/ 60; //Dhuhr
		if (this.method_params[this.calc_method,1] == 1) // Maghrib
			times[5] = times[4]+ this.method_params[this.calc_method,2]/ 60.0;

		if (this.method_params[this.calc_method,3] == 1) // Isha
			times[6] = times[5]+ this.method_params[this.calc_method,4]/ 60.0;

	    if(this.adjust_high_lats == 1) {
	        time = this.adjustHighLatTimes(times);
	    }
	    times = time;

		return times;
	}

	public string[] adjustTimesFormat(double[] times) {
		string[] formatted = new string[times.length];
		if(this.time_format == this.floats) {
			for(int i=0; i<times.length; ++i) {
				formatted[i] = times[i].to_string() + "";
			}
			return formatted;
		}

		for(int i=0; i<7; i++) {
			if(this.time_format == this.time12)
				formatted[i] = this.floatToTime12(times[i], true);
			else if(this.time_format == time12_ns)
				formatted[i] = this.floatToTime12NS(times[i]);
			else
				formatted[i] = this.floatToTime24(times[i]);
		}
		return formatted;
	}

	public double[] adjustHighLatTimes(double[] times) {
		double night_time =  this.getTimeDiff(times[4], times[1]); // sunset to sunrise

		// Adjust Fajr
		double FajrDiff =  this.nightPortion(this.method_params[this.calc_method, 0])* night_time;
		if (this.getTimeDiff(times[0], times[1]) > FajrDiff)
			times[0] = times[1]- FajrDiff;

		// Adjust Isha
		double IshaAngle = (this.method_params[this.calc_method, 3] == 0) ? this.method_params[this.calc_method, 4] : 18;
		double IshaDiff =  this.nightPortion(IshaAngle)* night_time;
		if (this.getTimeDiff(times[4], times[6]) > IshaDiff)
			times[6] = times[4]+ IshaDiff;

		// Adjust Maghrib
		double MaghribAngle = (this.method_params[this.calc_method,1] == 0) ? this.method_params[this.calc_method, 2] : 4;
		double MaghribDiff =  this.nightPortion(MaghribAngle)* night_time;
		if (this.getTimeDiff(times[4], times[5]) > MaghribDiff)
			times[5] = times[4]+ MaghribDiff;

		return times;
	}

	public double dsin(double d) {
		return Math.sin(this.degreeToRadian(d));
	}

	public double dcos(double d) {
		return Math.cos(this.degreeToRadian(d));
	}

	public double dtan(double d) {
		return Math.tan(this.degreeToRadian(d));
	}

	public double darcsin(double x) {
		return this.radianToDegree(Math.asin(x));
	}

	public double darccos(double x) {
		return this.radianToDegree(Math.acos(x));
	}

	public double darctan(double x) {
		return this.radianToDegree(Math.atan(x));
	}

	public double darctan2(double x, double y) {
		return this.radianToDegree(Math.atan2(x, y));
	}

	public double darccot(double x) {
		return this.radianToDegree(Math.atan(1/x));
	}

	public double fixAngle(double angel) {
		angel = angel - 360.0 * (Math.floor(angel / 360.0));
		angel = angel < 0? angel + 360.0: angel;
		return angel;
	}

	public double fixHour(double hour) {
		hour = hour - 24.0 * (Math.floor(hour / 24.0));
		hour = hour < 0? hour + 24.0: hour;
		return hour;
	}

	public double degreeToRadian(double degree) {
		return (degree * Math.PI) / 180.0;
	}

	public double radianToDegree(double radian) {
		return (radian * 180) / Math.PI;
	}
}