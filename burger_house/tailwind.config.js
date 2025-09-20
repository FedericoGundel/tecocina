module.exports = {
  content: ["./pages/*.{html,js}", "./index.html", "./js/*.js"],
  theme: {
    extend: {
      colors: {
        // Primary Colors - Amarillo Sol (main buttons, CTAs, highlights)
        primary: {
          DEFAULT: "#F9C74F", // amarillo-sol
          50: "#FEFCF4",
          100: "#FEF9E9", 
          200: "#FDF2D3",
          300: "#FCEBBD",
          400: "#FAE4A7",
          500: "#F9C74F", // amarillo-sol
          600: "#F7B82C",
          700: "#F5A909",
          800: "#D18F08",
          900: "#AE7506",
        },
        // Secondary Colors - Naranja Dorado (hover states, secondary buttons)
        secondary: {
          DEFAULT: "#F9844A", // naranja-dorado
          50: "#FEF6F2",
          100: "#FDEDE5",
          200: "#FBDBCB",
          300: "#F9C9B1",
          400: "#F7B797",
          500: "#F9844A", // naranja-dorado
          600: "#F76B27",
          700: "#F55204",
          800: "#D14403",
          900: "#AE3903",
        },
        // Accent Colors - Azul Cielo (special sections, highlights)
        accent: {
          DEFAULT: "#0096C7", // azul-cielo
          50: "#E6F6FC",
          100: "#CCECF9",
          200: "#99D9F3",
          300: "#66C6ED",
          400: "#33B3E7",
          500: "#0096C7", // azul-cielo
          600: "#0078A0",
          700: "#005A79",
          800: "#003C52",
          900: "#001E2B",
        },
        // Background Colors - Arena (light backgrounds)
        background: "#EADCA6", // arena/beige
        surface: "#FFFFFF", // white for cards
        "surface-light": "#90E0EF", // celeste claro for secondary backgrounds
        // Text Colors - Negro Profundo y Marrón Hamburguesa
        "text-primary": "#0D0D0D", // negro-profundo (strong text)
        "text-secondary": "#6A3E2F", // marrón-hamburguesa (secondary text)
        "text-muted": "#6B6B6B", // for subtle text
        // Status Colors (keeping existing for functionality)
        success: {
          DEFAULT: "#28A745", // green-600
          50: "#F0F9F3",
          100: "#E1F3E7",
          200: "#C3E7CF",
          300: "#A5DBB7",
          400: "#87CF9F",
          500: "#28A745", // green-600
          600: "#239B3E",
          700: "#1E8F37",
          800: "#198330",
          900: "#147729",
        },
        warning: {
          DEFAULT: "#FFC107", // amber-400
          50: "#FFFBF0",
          100: "#FFF7E0",
          200: "#FFEFC1",
          300: "#FFE7A2",
          400: "#FFDF83",
          500: "#FFC107", // amber-400
          600: "#E6AD06",
          700: "#CC9905",
          800: "#B38504",
          900: "#997103",
        },
        error: {
          DEFAULT: "#DC3545", // red-600
          50: "#FDF2F3",
          100: "#FCE5E7",
          200: "#F9CBCF",
          300: "#F6B1B7",
          400: "#F3979F",
          500: "#DC3545", // red-600
          600: "#C62E3E",
          700: "#B02737",
          800: "#9A2030",
          900: "#841929",
        },
        // Border Colors - matching the new palette
        border: "#C4B79F", // darker version of arena for borders
        "border-light": "#E0D6B8", // lighter version of arena
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontWeight: {
        normal: '400',
        medium: '500',
        semibold: '600',
        bold: '700',
      },
      borderRadius: {
        'lg': '8px',
        'xl': '12px',
      },
      boxShadow: {
        'sm': '0 2px 8px rgba(0, 0, 0, 0.1)',
        'md': '0 4px 16px rgba(0, 0, 0, 0.15)',
      },
      animation: {
        'scale-press': 'scale 150ms ease-out',
        'expand-height': 'expand 300ms ease-in-out',
        'shimmer': 'shimmer 2s linear infinite',
        'border-highlight': 'border 200ms ease-in-out',
        'swipe-remove': 'swipe 250ms ease-out',
        'toast-slide': 'toast-slide 4s cubic-bezier(0.68, -0.55, 0.265, 1.55)',
      },
      transitionDuration: {
        '150': '150ms',
        '200': '200ms',
        '250': '250ms',
        '300': '300ms',
      },
      transitionTimingFunction: {
        'ease-out': 'ease-out',
        'ease-in': 'ease-in',
        'ease-in-out': 'ease-in-out',
        'spring': 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
      },
      minHeight: {
        'touch': '44px',
      },
      minWidth: {
        'touch': '44px',
      },
    },
  },
  plugins: [],
}