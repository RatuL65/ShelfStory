import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'setup_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});


  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accentGold,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkBackground : AppColors.darkBrown,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ShelfStory Reader',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Account Settings
          _buildSectionHeader('Account', isDark),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Change Name',
            subtitle: 'Update your display name',
            isDark: isDark,
            onTap: _changeName,
          ),
          
          // App Settings
          _buildSectionHeader('App', isDark),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version info and details',
            isDark: isDark,
            onTap: _showAbout,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with the app',
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('For support, contact: support@shelfstory.app'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          
          // Dark Theme Toggle - NOW WORKING!
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Theme',
                subtitle: themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) async {
                    await themeProvider.setTheme(value);
                  },
                  activeColor: AppColors.accentGold,
                ),
                onTap: null,
              );
            },
          ),
          
          // Danger Zone
          const SizedBox(height: 20),
          _buildSectionHeader('Danger Zone', isDark),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Reset App',
            subtitle: 'Delete all data and start fresh',
            textColor: Colors.red,
            isDark: isDark,
            onTap: _resetApp,
          ),
          
          const SizedBox(height: 40),
          
          // App Version at Bottom
          Center(
            child: Column(
              children: [
                Text(
                  'ShelfStory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.5.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? AppColors.darkTextSecondary.withOpacity(0.6)
                        : AppColors.primaryBrown.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ for book lovers',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? AppColors.darkTextSecondary.withOpacity(0.6)
                        : AppColors.primaryBrown.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    Widget? trailing,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    final defaultTextColor = isDark ? AppColors.darkText : AppColors.darkBrown;
    final defaultSubtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.primaryBrown;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? defaultTextColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? defaultTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: (textColor ?? defaultSubtitleColor).withOpacity(0.7),
                ),
              )
            : null,
        trailing: trailing ?? 
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: defaultSubtitleColor,
                  )
                : null),
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
  
  Future<void> _changeName() async {
    final controller = TextEditingController();
    final currentName = Provider.of<UserProvider>(context, listen: false).user?.name ?? '';
    controller.text = currentName;
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter new name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (newName != null && newName.trim().isNotEmpty && newName != currentName) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName.trim());
      
      if (!mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserName(newName.trim());
      
      setState(() {});
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name updated to ${newName.trim()}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'ShelfStory',
      applicationVersion: '1.5.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.auto_stories,
          size: 40,
          color: AppColors.darkBrown,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Your personal vintage library tracker.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track your reading journey, organize your books, '
          'and never forget what you\'ve read. Built with ❤️ for book lovers.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Search books by title or author'),
        const Text('• Set yearly reading goals'),
        const Text('• Visual statistics and charts'),
        const Text('• Dark theme support'),
        const Text('• ISBN barcode scanning'),
        const Text('• Book rating system'),
        const SizedBox(height: 16),
        const Text(
          '© 2025 ShelfStory',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
  
  Future<void> _resetApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App?'),
        content: const Text(
          'This will DELETE ALL your books, stats, and account data. '
          'This action CANNOT be undone!\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        await Hive.box('books').clear();
        await Hive.box('user').clear();
        await Hive.box('settings').clear();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        if (!mounted) return;
        
        Navigator.pop(context);
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SetupScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
