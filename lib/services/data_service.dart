import '../models/tiffin.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/cart.dart';

class DataService {
  static List<Tiffin> getTiffins() {
    return [
      Tiffin(
        id: '1',
        name: 'Traditional Thali',
        description: 'Complete traditional meal with rice, dal, vegetables, and roti served in authentic brass container.',
        price: 180.0,
        metalType: 'Brass',
        category: 'Traditional',
        images: [
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500',
          'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500',
        ],
        isTrending: true,
        rating: 4.5,
        reviewCount: 234,
      ),
      Tiffin(
        id: '2',
        name: 'Steel Box Special',
        description: 'Hygienic and durable steel container with fresh homestyle cooking including sabzi, dal, and chapati.',
        price: 150.0,
        metalType: 'Steel',
        category: 'Modern',
        images: [
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500',
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500',
        ],
        isTrending: true,
        rating: 4.3,
        reviewCount: 189,
      ),
      Tiffin(
        id: '3',
        name: 'Silver Deluxe',
        description: 'Premium silver-coated container with royal taste experience featuring biryani and curry.',
        price: 250.0,
        metalType: 'Silver',
        category: 'Premium',
        images: [
          'https://images.unsplash.com/photo-1563379091339-03246962d51d?w=500',
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500',
        ],
        isTrending: false,
        rating: 4.8,
        reviewCount: 156,
      ),
      Tiffin(
        id: '4',
        name: 'Copper Classic',
        description: 'Traditional copper vessel with authentic flavors, includes seasonal vegetables and fresh bread.',
        price: 200.0,
        metalType: 'Copper',
        category: 'Traditional',
        images: [
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500',
          'https://images.unsplash.com/photo-1574484284002-952d92456975?w=500',
        ],
        isTrending: true,
        rating: 4.2,
        reviewCount: 98,
      ),
      Tiffin(
        id: '5',
        name: 'Aluminum Lite',
        description: 'Light weight aluminum container perfect for office lunch with balanced nutrition.',
        price: 120.0,
        metalType: 'Aluminum',
        category: 'Budget',
        images: [
          'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
          'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=500',
        ],
        isTrending: false,
        rating: 4.0,
        reviewCount: 67,
      ),
      Tiffin(
        id: '6',
        name: 'Bronze Heritage',
        description: 'Heritage bronze container maintaining traditional cooking methods with authentic taste.',
        price: 220.0,
        metalType: 'Bronze',
        category: 'Heritage',
        images: [
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500',
        ],
        isTrending: false,
        rating: 4.4,
        reviewCount: 142,
      ),
    ];
  }

  static List<String> getCategories() {
    return ['All', 'Traditional', 'Modern', 'Premium', 'Budget', 'Heritage'];
  }

  static List<String> getMetalTypes() {
    return ['All', 'Brass', 'Steel', 'Silver', 'Copper', 'Aluminum', 'Bronze'];
  }

  static List<String> getPriceRanges() {
    return ['All', 'Under ₹150', '₹150-₹200', '₹200-₹250', 'Above ₹250'];
  }

  static User getSampleUser() {
    return User(
      id: 'user_1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+91 9876543210',
      addresses: [
        DeliveryAddress(
          id: 'addr_1',
          label: 'Home',
          fullAddress: '123 Main Street, Apartment 4B',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400001',
          isDefault: true,
        ),
        DeliveryAddress(
          id: 'addr_2',
          label: 'Office',
          fullAddress: '456 Business Park, Floor 12',
          city: 'Mumbai',
          state: 'Maharashtra',
          pincode: '400002',
          isDefault: false,
        ),
      ],
      paymentMethods: [
        PaymentMethod(
          id: 'pay_1',
          type: 'card',
          displayName: 'Credit Card',
          details: '**** **** **** 1234',
          isDefault: true,
        ),
        PaymentMethod(
          id: 'pay_2',
          type: 'upi',
          displayName: 'UPI',
          details: 'john.doe@paytm',
          isDefault: false,
        ),
      ],
    );
  }

  static List<Order> getSampleOrders() {
    final user = getSampleUser();
    final tiffins = getTiffins();
    
    return [
      Order(
        id: 'order_1',
        items: [
          CartItem(
            id: 'item_1',
            tiffin: tiffins[0],
            quantity: 2,
          ),
        ],
        totalAmount: 360.0,
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryAddress: user.addresses[0],
        paymentMethod: user.paymentMethods[0],
        estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'order_2',
        items: [
          CartItem(
            id: 'item_2',
            tiffin: tiffins[1],
            quantity: 1,
          ),
          CartItem(
            id: 'item_3',
            tiffin: tiffins[2],
            quantity: 1,
          ),
        ],
        totalAmount: 400.0,
        status: OrderStatus.outForDelivery,
        orderDate: DateTime.now().subtract(const Duration(hours: 4)),
        deliveryAddress: user.addresses[0],
        paymentMethod: user.paymentMethods[1],
        estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
      ),
    ];
  }
}