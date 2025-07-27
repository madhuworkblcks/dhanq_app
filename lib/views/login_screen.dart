import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            // Initialize the viewmodel when the widget is first built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!viewModel.isInitialized) {
                viewModel.initialize();
              }
            });
            
            return _buildBody(viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildBody(LoginViewModel viewModel) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Logo and Title
            _buildHeader(),

            const SizedBox(height: 40),

            // Login Methods
            _buildLoginMethods(viewModel),

            const SizedBox(height: 32),

            // Phone Number Input
            if (viewModel.selectedMethod == LoginMethod.mobile)
              _buildPhoneInput(viewModel),

            // mPIN Input (includes mobile number)
            if (viewModel.selectedMethod == LoginMethod.mpin)
              _buildMpinInput(viewModel),

            // Error Message
            if (viewModel.errorMessage.isNotEmpty)
              _buildErrorMessage(viewModel),

            const SizedBox(height: 24),

            // Continue Button
            _buildContinueButton(viewModel),

            const Spacer(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'D',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Q',
                    style: TextStyle(
                      color: Color(0xFFEB5D37),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Welcome to ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: 'Dhan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              TextSpan(
                text: 'Q',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEB5D37),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your Financial Companion',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoginMethods(LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Login Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                'Mobile',
                Icons.phone_android,
                LoginMethod.mobile,
                viewModel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                'mPIN',
                Icons.lock,
                LoginMethod.mpin,
                viewModel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                'Biometric',
                Icons.fingerprint,
                LoginMethod.biometric,
                viewModel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    String title,
    IconData icon,
    LoginMethod method,
    LoginViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedMethod == method;

    return GestureDetector(
      onTap: () => viewModel.setLoginMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF1E3A8A).withOpacity(0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFF1E3A8A), width: 2)
                  : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMpinInput(LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile Number Input
        const Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // mPIN Input
        const Text(
          'mPIN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: viewModel.mpinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            hintText: 'Enter 6-digit mPIN',
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(LoginViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            viewModel.isLoading
                ? null
                : () {
                  viewModel.handleLogin().then((success) {
                    if (success) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  });
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            viewModel.isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'By continuing, you agree to our',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to terms
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              ' and ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to privacy policy
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
