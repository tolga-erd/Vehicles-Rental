let currentVehiclePrice = 0;
let currentVehicleName = '';
let currentVehicleModel = '';
let currentVehiclePlate = '';
let VEHICLES = {};
let returnRent = 0;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'showUI') {
        showUI();
    } else if (data.type === 'hideUI') {
        hideUI();
    } else if (data.type === 'vehiclesData') {
        returnLoad(data.data);
        vehicleLoad(data.ownVeh)
        VEHICLES = data.data
        returnRent = data.returnRent;
        console.log(data)
    }
});
function showUI() {
    const app = document.getElementById('app');
    app.style.display = 'block';
    app.classList.add('show');
    document.body.style.pointerEvents = 'auto';
}function hideUI() {
    const app = document.getElementById('app');
    app.classList.add('hide');
    setTimeout(() => {
        app.style.display = 'none';
        app.classList.remove('show', 'hide');
    }, 300);
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}
function closeUI() {
    hideUI();
}
function openRentalModal(model, vehicle) {
    currentVehicleName = vehicle.label;
    currentVehicleModel = model;
    if (vehicle.plate) {
        currentVehiclePlate = vehicle.plate;
        currentVehiclePrice = (VEHICLES[model].price / 100) * returnRent;
        document.getElementById('confirm').textContent = "Get Deposit";
    } else {
        currentVehiclePlate = '';
        currentVehiclePrice = vehicle.price ?? VEHICLES[model].price;
        document.getElementById('confirm').textContent = "Rent";
    }
    document.getElementById('modalTitle').textContent = vehicle.label;
    document.getElementById('rentalModal').style.display = 'block';
    document.getElementById('rent-image').style.backgroundImage = `url(https://docs.fivem.net/vehicles/${model}.webp)`;
    updateTotal();
}
function closeRentalModal() {
    document.getElementById('rentalModal').style.display = 'none';
}
function updateTotal() {
    const total = (currentVehiclePrice);
    document.getElementById('totalPrice').textContent = `$${total}`;
}
function confirmRental() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            vehicleName: currentVehicleModel,
            plate: currentVehiclePlate
        })
    });
    currentVehiclePlate = '';
    closeRentalModal();
    hideUI();
}
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (document.getElementById('rentalModal').style.display === 'block') {
            closeRentalModal();
        } else {
            closeUI();
        }
    }
});
window.onclick = function(event) {
    const modal = document.getElementById('rentalModal');
    if (event.target === modal) {
        closeRentalModal();
    }
}
function vehicleLoad(data) {
    const grid = document.getElementById("vehiclesGrid");
    if (!grid) return;
    grid.innerHTML = "";
    Object.entries(data).forEach(([key, vehicle]) => {
        const card = document.createElement("div");
        card.classList.add("vehicle-card");
        card.onclick = () => openRentalModal(vehicle.model, vehicle);
        card.innerHTML = `
            <div class="vehicle-image" style="background-image: url(https://docs.fivem.net/vehicles/${vehicle.model}.webp)">
                <div class="vehicle-info">
                    <div class="vehicle-name">${vehicle.label}</div>
                </div>
            </div>
        `;
        grid.appendChild(card);
    });
}
function returnLoad(data) {
    const grid = document.querySelector('.return-menu ul');
    if (!grid) return;
    grid.innerHTML = "";
    Object.entries(data).forEach(([key, vehicle]) => {
        const card = document.createElement("div");
        card.classList.add("vehicle-card");
        card.onclick = () => openRentalModal(key, vehicle);
        card.innerHTML = `
            <div class="vehicle-image" style="background-image: url(https://docs.fivem.net/vehicles/${key}.webp)">
                <div class="vehicle-info">
                    <div class="vehicle-name">${vehicle.label}</div>
                    <div class="vehicle-price">$${vehicle.price}</div>
                </div>
            </div>
        `;
        grid.appendChild(card);
    });
}
document.querySelector('.return-open').addEventListener('click', () => {
  const menu = document.querySelector('.return-menu');
  menu.classList.toggle('active');
});