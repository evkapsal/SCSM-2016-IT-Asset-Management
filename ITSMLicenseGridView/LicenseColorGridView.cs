using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Data;
using System.Globalization;

namespace ITSMLicenseGridView
{
    public class LicenseColorGridView : IValueConverter
    {
        private static readonly LicenseColorGridView _default = new LicenseColorGridView();
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if ((value != null))
            {
                if (value is Int32)
                {
                    Int32 prio = Int32.Parse(value.ToString());
                    switch (prio)
                    {
                        case (1):
                            return "Red";
                        case (2):
                            return "Orange";
                        case (3):
                            return "LightGreen";
                        default:
                            return "White";
                    }
                }
            }
            return "White";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }

        public static LicenseColorGridView Default
        {
            get
            {
                LicenseColorGridView converter;
                converter = _default;
                return converter;
            }
        }
    }
}
