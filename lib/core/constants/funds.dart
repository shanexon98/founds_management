import 'package:management_funds/features/funds/domain/entities/fund.dart';

const availableFunds = <Fund>[
  Fund(
    id: 1,
    name: 'FPV_BTG_PACTUAL_RECAUDADORA COP',
    minAmount: 75000,
    category: 'FPV',
  ),
  Fund(
    id: 2,
    name: 'FPV_BTG_PACTUAL_ECOPETROL COP',
    minAmount: 125000,
    category: 'FPV',
  ),
  Fund(
    id: 3,
    name: 'DEUDAPRIVADA COP',
    minAmount: 50000,
    category: 'FIC',
  ),
  Fund(
    id: 4,
    name: 'FDO-ACCIONES COP',
    minAmount: 250000,
    category: 'FIC',
  ),
  Fund(
    id: 5,
    name: 'FPV_BTG_PACTUAL_DINAMICA COP',
    minAmount: 100000,
    category: 'FPV',
  ),
];
