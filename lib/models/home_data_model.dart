import 'activity_model.dart';
import 'financial_service_model.dart';
import 'portfolio_model.dart';

class HomeDataModel {
  final PortfolioModel portfolio;
  final List<ActivityModel> activities;
  final Map<String, List<FinancialServiceModel>> financialServices;
  final Map<String, double> portfolioBreakdown;
  final UserProfileModel userProfile;

  HomeDataModel({
    required this.portfolio,
    required this.activities,
    required this.financialServices,
    required this.portfolioBreakdown,
    required this.userProfile,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    // Convert all values in portfolioBreakdown to double, even if they are int
    final rawBreakdown = json['portfolioBreakdown'] as Map<String, dynamic>;
    final breakdown = rawBreakdown.map(
      (key, value) =>
          MapEntry(key, (value is int) ? value.toDouble() : value as double),
    );
    return HomeDataModel(
      portfolio: PortfolioModel.fromJson(json['portfolio']),
      activities:
          (json['activities'] as List)
              .map((activity) => ActivityModel.fromJson(activity))
              .toList(),
      financialServices: {
        'urban':
            (json['financialServices']['urban'] as List)
                .map((service) => FinancialServiceModel.fromJson(service))
                .toList(),
        'rural':
            (json['financialServices']['rural'] as List)
                .map((service) => FinancialServiceModel.fromJson(service))
                .toList(),
      },
      portfolioBreakdown: breakdown,
      userProfile: UserProfileModel.fromJson(json['userProfile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio': portfolio.toJson(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'financialServices': {
        'urban':
            financialServices['urban']!
                .map((service) => service.toJson())
                .toList(),
        'rural':
            financialServices['rural']!
                .map((service) => service.toJson())
                .toList(),
      },
      'portfolioBreakdown': portfolioBreakdown,
      'userProfile': userProfile.toJson(),
    };
  }
}

class UserProfileModel {
  final String name;
  final String mobile;
  final String email;
  final bool onboardingCompleted;

  UserProfileModel({
    required this.name,
    required this.mobile,
    required this.email,
    required this.onboardingCompleted,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      onboardingCompleted: json['onboardingCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'onboardingCompleted': onboardingCompleted,
    };
  }
}
