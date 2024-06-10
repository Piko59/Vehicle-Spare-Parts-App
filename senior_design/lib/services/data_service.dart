class DataService {
  static final Map<String, List<String>> vehicleCategories = {
    'Car': [
      'Ignition & Fuel',
      'Exhaust',
      'Electric',
      'Filter',
      'Brake & Clutch',
      'Mechanical',
      'Engine',
      'Transmission & Gear',
      'Steering & Suspension',
    ],
    'Motorcycle': [
      'Clutch',
      'Exhaust',
      'Electric',
      'Brake',
      'Fairing',
      'Ventilation',
      'Engine',
      'Suspension',
      'Transmission',
      'Lubrication',
      'Fuel System',
      'Steering',
    ],
    'Bicycle': [
      'Handlebar',
      'Brake',
      'Rotor',
      'Bearing',
      'Rim',
      'Frame',
      'Drivetrain Components',
      'Electric Components',
      'Cockpit',
      'Brake Pad',
    ],
  };

  static final Map<String, List<String>> vehicleBrands = {
    'Car': [
      'Toyota',
      'Honda',
      'Ford',
      'BMW',
      'Mercedes',
    ],
    'Motorcycle': [
      'Yamaha',
      'Honda',
      'Suzuki',
      'Kawasaki',
      'Ducati',
    ],
    'Bicycle': [
      'Giant',
      'Trek',
      'Specialized',
      'Cannondale',
      'Bianchi',
    ],
  };
}
