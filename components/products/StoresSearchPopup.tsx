"use client";

import { useState, useRef, useCallback,useEffect } from "react";
import DataGridView from "../common/DataGridView";
import Button from "../common/Button";
import * as wjGrid from "@grapecity/wijmo.grid";

interface Store {
    id: number;
    warehouse_name: string;
    code: string;
}

interface StoresSearchPopupProps {
    visible: boolean;
    onClose: () => void;
    onSelect: (store: Store) => void;
    stores: Store[];
}

const StoresSearchPopup: React.FC<StoresSearchPopupProps> = ({
    visible,
    onClose,
    onSelect,
    stores,
}) => {
    const [selectedStore, setSelectedStore] = useState<Store | null>(null);
    const gridRef = useRef<wjGrid.FlexGrid | null>(null);



    const handleRowDoubleClick = useCallback(
        (store: Store) => {
            onSelect(store);
            onClose();
        },
        [onSelect, onClose]
    );

    const handleSelectionChange = useCallback((grid: wjGrid.FlexGrid) => {
        if (!grid) return;
        const rowIndex = grid.selection?.row ?? -1;
        if (rowIndex < 0) return;
        const item = grid.rows[rowIndex]?.dataItem as Store | undefined;
        if (!item) return;
        setSelectedStore(item);
    }, []);
    useEffect(() => {
        if (!visible) return;

        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape") {
                e.preventDefault();
                onClose();
            }

        };

        window.addEventListener("keydown", handleKeyDown, true);

        return () => {
            window.removeEventListener("keydown", handleKeyDown, true);
        };
    }, [visible, onClose]);
    if (!visible) return null;
    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
            <div
                className="bg-white rounded-lg shadow-2xl border p-6 w-full max-w-4xl"
                dir="rtl"
                style={{ height: "650px" }}
            >
                <h3 className="text-lg font-semibold mb-4 text-right">
                    اختيار المستودع
                </h3>

                <DataGridView
                    ref={gridRef}
                    dataSource={stores}
                    scheme={{
                        isReport: true,
                        columns: [
                            { header: "رقم المستودع", name: "id", width: 120, isReadOnly: true },
                            { header: "اسم المستودع", name: "name", width: "*", isReadOnly: true },
                        ],
                    }}
                    selectionChanged={handleSelectionChange}
                    onRowDoubleClick={handleRowDoubleClick}
                />

                <div className="flex justify-center gap-3 mt-4">
                    <Button
                        className="erp-btn-primary"
                        disabled={!selectedStore}
                        onClick={() => {
                            if (!selectedStore) return;
                            onSelect(selectedStore);
                            onClose();
                        }}
                    >
                        موافق
                    </Button>
                    <Button className="erp-btn-primary" variant="outline" onClick={onClose}>
                        إغلاق
                    </Button>
                </div>
            </div>
        </div>
    );
};

export default StoresSearchPopup;
