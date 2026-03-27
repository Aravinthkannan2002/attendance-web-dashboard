import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employees_controller.dart';
import '../core/app_theme.dart';
import '../models/employee_model.dart';
import '../services/dashboard_service.dart';
import '../widgets/shimmer_loading.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EmployeesController>()) {
      if (!Get.isRegistered<DashboardService>()) {
        Get.put(DashboardService(), permanent: true);
      }
      Get.put(EmployeesController());
    }
    final controller = Get.find<EmployeesController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final contentPadding = isNarrow ? 16.0 : 28.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmployeesHeader(controller: controller, isNarrow: isNarrow),
              SizedBox(height: isNarrow ? 20 : 24),

              Obx(() {
                if (controller.isLoading.value) {
                  return const TableShimmer(rows: 6, columns: 5);
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorCard(
                    message: controller.errorMessage.value,
                    onRetry: controller.refresh,
                  );
                }

                if (controller.filteredEmployees.isEmpty) {
                  return _EmptyState(
                    hasSearch: controller.searchQuery.value.isNotEmpty,
                  );
                }

                return _EmployeesTableCard(controller: controller);
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _EmployeesHeader extends StatelessWidget {
  final EmployeesController controller;
  final bool isNarrow;
  const _EmployeesHeader({required this.controller, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _EmployeeCountBadge(count: controller.employees.length),
                ],
              )),
          const SizedBox(height: 16),
          TextField(
            onChanged: controller.onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name, ID or dept...',
              prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.textSecondaryOf(context)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.borderColorOf(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.borderColorOf(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              filled: true,
              fillColor: AppTheme.cardColorOf(context),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          _RefreshButton(onPressed: controller.refresh),
        ],
      );
    }

    return Row(
      children: [
        Obx(() => Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryOf(context),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _EmployeeCountBadge(count: controller.employees.length),
                  ],
                ),
              ],
            )),

        const Spacer(),

        SizedBox(
          width: 280,
          child: TextField(
            onChanged: controller.onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name, ID or dept...',
              prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.textSecondaryOf(context)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.borderColorOf(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.borderColorOf(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              filled: true,
              fillColor: AppTheme.cardColorOf(context),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(Icons.person_add_rounded, size: 16),
          label: const Text('Add Employee'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 8),
        _RefreshButton(onPressed: controller.refresh),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddEmployeeDialog(controller: controller),
    );
  }
}

class _EmployeeCountBadge extends StatelessWidget {
  final int count;
  const _EmployeeCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count employees',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColorOf(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Table card ─────────────────────────────────────────────────────────────

class _EmployeesTableCard extends StatelessWidget {
  final EmployeesController controller;
  const _EmployeesTableCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 80,
              ),
              child: Column(
                children: [
                  _TableHeader(),
                  Obx(() {
                    final rows = controller.paginatedEmployees;
                    final startIndex =
                        controller.currentPage.value * EmployeesController.pageSize;

                    return Column(
                      children: rows.asMap().entries.map((entry) {
                        final index = startIndex + entry.key + 1;
                        final employee = entry.value;
                        return _EmployeeRow(
                          index: index,
                          employee: employee,
                          controller: controller,
                          isEven: entry.key % 2 == 0,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: AppTheme.borderColorOf(context)),

          Obx(() => _PaginationBar(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages,
                totalItems: controller.filteredEmployees.length,
                pageSize: EmployeesController.pageSize,
                hasPrev: controller.hasPrevPage,
                hasNext: controller.hasNextPage,
                onPrev: controller.prevPage,
                onNext: controller.nextPage,
              )),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : AppTheme.primaryColor.withValues(alpha: 0.03);
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.textSecondaryOf(context),
      letterSpacing: 0.8,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColorOf(context)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: headerStyle)),
          SizedBox(width: 180, child: Text('NAME', style: headerStyle)),
          SizedBox(width: 120, child: Text('EMPLOYEE ID', style: headerStyle)),
          SizedBox(width: 120, child: Text('DEPARTMENT', style: headerStyle)),
          SizedBox(width: 120, child: Text('DESIGNATION', style: headerStyle)),
          SizedBox(width: 120, child: Text('FACE REGISTERED', style: headerStyle)),
          SizedBox(width: 80, child: Text('STATUS', style: headerStyle)),
          SizedBox(width: 80, child: Text('ACTIONS', style: headerStyle)),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatefulWidget {
  final int index;
  final EmployeeModel employee;
  final EmployeesController controller;
  final bool isEven;
  const _EmployeeRow({
    required this.index,
    required this.employee,
    required this.controller,
    required this.isEven,
  });

  @override
  State<_EmployeeRow> createState() => _EmployeeRowState();
}

class _EmployeeRowState extends State<_EmployeeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employee = widget.employee;
    final initials = employee.name.isNotEmpty
        ? employee.name
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
        : '?';

    final stripeBg = widget.isEven
        ? Colors.transparent
        : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015));
    final hoverBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppTheme.primaryColor.withValues(alpha: 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? hoverBg : stripeBg,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.borderColorOf(context).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '${widget.index}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryOf(context),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.15),
                          AppTheme.primaryColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        initials.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColorOf(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  employee.employeeId.isNotEmpty ? employee.employeeId : '-',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                employee.department?.isNotEmpty == true ? employee.department! : '-',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimaryOf(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                employee.designation?.isNotEmpty == true ? employee.designation! : '-',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimaryOf(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: _FaceRegisteredChip(registered: employee.isFaceRegistered),
            ),
            SizedBox(
              width: 80,
              child: _StatusChip(isActive: employee.isActive),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  _ActionIcon(
                    icon: Icons.edit_outlined,
                    color: AppTheme.primaryColor,
                    tooltip: 'Edit',
                    onPressed: () => _showEditDialog(context),
                  ),
                  const SizedBox(width: 4),
                  _ActionIcon(
                    icon: employee.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_add_outlined,
                    color: employee.isActive
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    tooltip: employee.isActive ? 'Deactivate' : 'Activate',
                    onPressed: () => _showToggleDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditEmployeeDialog(
        employee: widget.employee,
        controller: widget.controller,
      ),
    );
  }

  void _showToggleDialog(BuildContext context) {
    final employee = widget.employee;
    final action = employee.isActive ? 'deactivate' : 'activate';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${action[0].toUpperCase()}${action.substring(1)} Employee'),
        content: Text('Are you sure you want to $action ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.controller.toggleActive(employee);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: employee.isActive ? AppTheme.errorColor : AppTheme.successColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

class _FaceRegisteredChip extends StatelessWidget {
  final bool registered;
  const _FaceRegisteredChip({required this.registered});

  @override
  Widget build(BuildContext context) {
    final color = registered ? AppTheme.successColor : AppTheme.errorColor;
    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            registered ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            registered ? 'Registered' : 'Not Set',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.successColor : AppTheme.textSecondary;
    return Container(
      constraints: const BoxConstraints(maxWidth: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Pagination bar ─────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final from = (currentPage * pageSize + 1).clamp(1, totalItems);
    final to = ((currentPage + 1) * pageSize).clamp(1, totalItems);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            'Showing $from\u2013$to of $totalItems employees',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNarrow) ...[
                Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              _PageButton(icon: Icons.chevron_left, enabled: hasPrev, onTap: onPrev),
              const SizedBox(width: 6),
              _PageButton(icon: Icons.chevron_right, enabled: hasNext, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppTheme.cardColorOf(context) : AppTheme.surfaceColorOf(context),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColorOf(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppTheme.textPrimaryOf(context) : AppTheme.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.people_outline,
                size: 36,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No employees match your search' : 'No employees found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'Employees added via the mobile app will appear here',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Employee Dialog ──────────────────────────────────────────────────

class _AddEmployeeDialog extends StatefulWidget {
  final EmployeesController controller;
  const _AddEmployeeDialog({required this.controller});

  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _nameCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _desigCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _empIdCtrl.dispose();
    _deptCtrl.dispose();
    _desigCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await widget.controller.addEmployee(
      name: _nameCtrl.text.trim(),
      employeeId: _empIdCtrl.text.trim().isEmpty ? null : _empIdCtrl.text.trim(),
      department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      designation: _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
    );
    if (mounted) {
      if (ok) {
        Navigator.pop(context);
      } else {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_rounded, color: AppTheme.primaryColor, size: 22),
          SizedBox(width: 10),
          Text('Add Employee'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _empIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  hintText: 'e.g. EMP001',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _deptCtrl,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.business_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _desigCtrl,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  prefixIcon: Icon(Icons.work_outline, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'After adding, register their face on the kiosk tablet.',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Add Employee'),
        ),
      ],
    );
  }
}

// ── Edit Employee Dialog ─────────────────────────────────────────────────

class _EditEmployeeDialog extends StatefulWidget {
  final EmployeeModel employee;
  final EmployeesController controller;

  const _EditEmployeeDialog({
    required this.employee,
    required this.controller,
  });

  @override
  State<_EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<_EditEmployeeDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _empIdCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _desigCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.employee.name);
    _empIdCtrl = TextEditingController(text: widget.employee.employeeId);
    _deptCtrl = TextEditingController(text: widget.employee.department ?? '');
    _desigCtrl = TextEditingController(text: widget.employee.designation ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _empIdCtrl.dispose();
    _deptCtrl.dispose();
    _desigCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.controller.updateEmployee(
      widget.employee,
      name: _nameCtrl.text.trim(),
      employeeId: _empIdCtrl.text.trim(),
      department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      designation: _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width < 500
        ? MediaQuery.of(context).size.width * 0.9
        : 420.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          const Text('Edit Employee'),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _empIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _deptCtrl,
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _desigCtrl,
              decoration: const InputDecoration(
                labelText: 'Designation',
                prefixIcon: Icon(Icons.work_outline, size: 20),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

// ── Error card ─────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColorOf(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.error_outline, size: 32, color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: AppTheme.textSecondaryOf(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
