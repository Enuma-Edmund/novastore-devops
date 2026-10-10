
import { useEffect, useState } from 'react'
import './App.css'

function App() {
  const [products, setProducts] = useState([])
  const [cart, setCart] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  // Retrieve products from the Spring Boot backend
  useEffect(() => {
    async function loadProducts() {
      try {
        const response = await fetch('/api/products')

        if (!response.ok) {
          throw new Error(`API returned ${response.status}`)
        }

        const data = await response.json()
        setProducts(data)
        setError('')
      } catch (err) {
        console.error('Failed to load products:', err)
        setError('Unable to load products. Please try again.')
      } finally {
        setLoading(false)
      }
    }

    loadProducts()
  }, [])

  // Add a product to the shopping cart
  const addToCart = (product) => {
    setCart((current) => {
      const existing = current.find((item) => item.id === product.id)
      const quantity = existing?.quantity ?? 0

      if (quantity >= product.stock) {
        return current
      }

      if (existing) {
        return current.map((item) =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        )
      }

      return [...current, { ...product, quantity: 1 }]
    })
  }

  // Calculate cart totals
  const itemCount = cart.reduce(
    (sum, item) => sum + item.quantity,
    0
  )

  const total = cart.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  )

  return (
    <div className="store">
      <header className="store-header">
        <div className="brand">
          NOVA<span>STORE</span>
        </div>

        <div className="cart-indicator">
          🛒 Cart ({itemCount})
        </div>
      </header>

      <section className="store-hero">
        <p className="eyebrow">THE EVERYDAY TECH EDIT</p>

        <h1>Better tech. Simpler shopping.</h1>

        <p>
          Discover practical technology for work, home,
          and everything in between.
        </p>

        <a href="#products" className="shop-link">
          Shop collection →
        </a>
      </section>

      <main className="store-content" id="products">
        <div className="section-heading">
          <div>
            <p className="eyebrow">CURATED COLLECTION</p>
            <h2>Featured products</h2>
          </div>

          <span>{products.length} products</span>
        </div>

        {loading && (
          <p role="status">Loading products...</p>
        )}

        {error && (
          <p role="alert" style={{ color: '#c0392b' }}>
            {error}
          </p>
        )}

        {!loading && !error && products.length === 0 && (
          <p>No products are currently available.</p>
        )}

        {!loading && !error && (
          <div className="product-grid">
            {products.map((product) => (
              <article className="product-card" key={product.id}>
                <div className="product-image" aria-hidden="true">
                  {product.icon}
                </div>

                <div className="product-info">
                  <p className="category">
                    {product.category}
                  </p>

                  <h3>{product.name}</h3>

                  <p className="stock">
                    {product.stock} available
                  </p>

                  <div className="product-bottom">
                    <strong>
                      ${product.price.toFixed(2)}
                    </strong>

                    <button
                      type="button"
                      onClick={() => addToCart(product)}
                      disabled={product.stock === 0}
                    >
                      {product.stock === 0
                        ? 'Out of stock'
                        : 'Add to cart +'}
                    </button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}

        <section className="cart-summary">
          <div>
            <p className="eyebrow">YOUR SELECTION</p>
            <h2>Shopping cart</h2>

            <p>
              {itemCount === 0
                ? 'Your cart is empty.'
                : `${itemCount} item(s) in your cart`}
            </p>
          </div>

          <div className="cart-total">
            <span>Subtotal</span>
            <strong>${total.toFixed(2)}</strong>
          </div>
        </section>
      </main>

      <footer>
        © 2026 NovaStore · Retail platform engineering demonstration
      </footer>
    </div>
  )
}

export default App
